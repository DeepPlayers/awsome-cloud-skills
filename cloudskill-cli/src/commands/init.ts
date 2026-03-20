import chalk from 'chalk';
import ora from 'ora';
import prompts from 'prompts';
import { existsSync } from 'node:fs';
import { homedir } from 'node:os';
import { join, resolve } from 'node:path';
import type { CloudProvider, AIType } from '../types/index.js';
import { CLOUD_PROVIDERS, AI_TYPES, CLOUD_FOLDERS, AI_FOLDERS } from '../types/index.js';
import { logger } from '../utils/logger.js';
import { detectAIType, detectCloudProvider, getAITypeDescription, getCloudProviderDescription } from '../utils/detect.js';
import {
  getLatestRelease,
  getAssetUrl,
  downloadRelease,
  GitHubRateLimitError,
  GitHubDownloadError,
} from '../utils/github.js';
import { createTempDir, cleanup, copyFolders } from '../utils/extract.js';

interface InitOptions {
  provider?: CloudProvider;
  ai?: AIType;
  global?: boolean;
  path?: string;
  force?: boolean;
  offline?: boolean;
}

/**
 * Get the AI IDE skills directory path
 * @param aiType - AI IDE type
 * @param installPath - Custom install path (or 'global' for home directory)
 */
function getAISkillsPath(aiType: AIType, installPath?: string | boolean): string {
  const homeDir = homedir();
  
  // Determine the base directory
  let baseDir: string;
  if (typeof installPath === 'string') {
    // Custom path provided
    baseDir = resolve(installPath);
  } else if (installPath === true) {
    // Global installation to home directory
    baseDir = homeDir;
  } else {
    // Current working directory
    baseDir = process.cwd();
  }

  // Get the AI IDE folder name
  const targetAI = aiType === 'all' ? 'claude' : aiType;
  const aiFolders = AI_FOLDERS[targetAI] || ['.claude'];
  
  // Use the first folder as the base (e.g., .qoder, .claude, .cursor)
  const aiFolder = aiFolders[0];
  
  // For Claude-like IDEs, skills go to {folder}/skills/
  // For others, also use {folder}/skills/ for consistency
  return join(baseDir, aiFolder, 'skills');
}

/**
 * Get the target directory where AI IDE folder should be created
 */
function getTargetBaseDir(installPath?: string | boolean): string {
  if (typeof installPath === 'string') {
    return resolve(installPath);
  } else if (installPath === true) {
    return homedir();
  } else {
    return process.cwd();
  }
}

/**
 * Find the project root directory containing skills
 * Looks for:
 * 1. {cwd}/skills/{cloud-skill} -> returns {cwd}
 * 2. {cwd}/{cloud-skill} -> returns {cwd}
 * 3. {cwd}/../skills/{cloud-skill} -> returns {cwd}/..
 * 4. {cwd}/../{cloud-skill} -> returns {cwd}/..
 */
function findSkillSourceDir(cwd: string, provider: CloudProvider): string | null {
  const folders = provider === 'all'
    ? ['alibaba-cloud-skill', 'aws-cloud-skill']
    : CLOUD_FOLDERS[provider] || [];

  // Check current directory and its subdirectories
  const searchLocations = [
    cwd,                          // {cwd}/alibaba-cloud-skill or {cwd}/skills/alibaba-cloud-skill
    join(cwd, '..'),              // {cwd}/../alibaba-cloud-skill or {cwd}/../skills/alibaba-cloud-skill
  ];

  for (const location of searchLocations) {
    for (const folder of folders) {
      // Check direct placement: {location}/{folder}
      if (existsSync(join(location, folder))) {
        return location;
      }
      // Check in skills subdirectory: {location}/skills/{folder}
      if (existsSync(join(location, 'skills', folder))) {
        return location;
      }
    }
  }

  return null;
}

async function tryGitHubInstall(
  targetDir: string,
  provider: CloudProvider,
  spinner: ReturnType<typeof ora>
): Promise<string[] | null> {
  let tempDir: string | null = null;

  try {
    spinner.text = 'Fetching latest release from GitHub...';
    const release = await getLatestRelease();
    const assetUrl = getAssetUrl(release);

    if (!assetUrl) {
      throw new GitHubDownloadError('No ZIP asset found in latest release');
    }

    spinner.text = `Downloading ${release.tag_name}...`;
    tempDir = await createTempDir();
    const zipPath = join(tempDir, 'release.zip');

    await downloadRelease(assetUrl, zipPath);

    spinner.text = 'Extracting and installing files...';
    const copiedFolders = await copyFolders(tempDir, targetDir, provider);

    await cleanup(tempDir);

    return copiedFolders;
  } catch (error) {
    if (tempDir) {
      await cleanup(tempDir);
    }

    if (error instanceof GitHubRateLimitError) {
      spinner.warn('GitHub rate limit reached, falling back...');
      return null;
    }

    if (error instanceof GitHubDownloadError) {
      spinner.warn('GitHub download failed, falling back...');
      return null;
    }

    if (error instanceof TypeError && error.message.includes('fetch')) {
      spinner.warn('Network error, falling back...');
      return null;
    }

    spinner.warn('Download failed, falling back...');
    return null;
  }
}

async function copyFromSource(
  searchDir: string,
  targetDir: string,
  provider: CloudProvider,
  aiType: AIType,
  spinner: ReturnType<typeof ora>,
  installPath?: string | boolean
): Promise<{ cloudFolders: string[]; aiFolders: string[]; skillsDirs: string[] }> {
  const { mkdir } = await import('node:fs/promises');
  
  spinner.text = 'Looking for skill source directory...';

  // Find the project root containing skills, relative to searchDir
  const projectRoot = findSkillSourceDir(searchDir, provider);

  if (!projectRoot) {
    return { cloudFolders: [], aiFolders: [], skillsDirs: [] };
  }

  spinner.text = `Copying from ${projectRoot}...`;

  try {
    // Determine the actual source directory containing skill folders
    // Check if skills are in skills/ subdirectory
    const folders = provider === 'all'
      ? ['alibaba-cloud-skill', 'aws-cloud-skill']
      : CLOUD_FOLDERS[provider] || [];
    
    let sourceDir = projectRoot;
    // Check if skills are in skills/ subdirectory
    if (existsSync(join(projectRoot, 'skills', folders[0]))) {
      sourceDir = join(projectRoot, 'skills');
    }

    // Get the AI IDE folder name
    const targetAIType = aiType === 'all' ? 'claude' : aiType;
    const aiFolderNames = AI_FOLDERS[targetAIType] || ['.claude'];
    const aiFolder = aiFolderNames[0];

    // Determine base directory for AI IDE
    const baseDir = getTargetBaseDir(installPath);
    
    // Create the AI IDE folder structure: {baseDir}/{.qoder}/skills/
    const aiDir = join(baseDir, aiFolder);
    const skillsDir = join(aiDir, 'skills');
    
    await mkdir(aiDir, { recursive: true });
    await mkdir(skillsDir, { recursive: true });

    // Copy cloud skill folders to the skills directory
    const cloudFolders = await copyFolders(sourceDir, skillsDir, provider);

    const skillsDirs = [skillsDir];
    const aiFolders = [aiFolder];

    return { cloudFolders, aiFolders, skillsDirs };
  } catch (error) {
    return { cloudFolders: [], aiFolders: [], skillsDirs: [] };
  }
}

export async function initCommand(options: InitOptions): Promise<void> {
  logger.title('Cloud Skills Installer');

  let provider = options.provider || 'alibaba-cloud';
  let aiType = options.ai;

  // Auto-detect or prompt for AI IDE
  if (!aiType) {
    const { detected, suggested } = detectAIType();

    if (detected.length > 0) {
      logger.info(`Detected AI IDEs: ${detected.map(t => chalk.cyan(getAITypeDescription(t))).join(', ')}`);
    }

    const response = await prompts({
      type: 'select',
      name: 'aiType',
      message: 'Select AI IDE to install skill for:',
      choices: AI_TYPES.map(type => ({
        title: getAITypeDescription(type),
        value: type,
      })),
      initial: suggested ? AI_TYPES.indexOf(suggested) : 0,
    });

    if (!response.aiType) {
      logger.warn('Installation cancelled');
      return;
    }

    aiType = response.aiType as AIType;
  }

  // Determine installation path
  const installPath = options.global ? true : options.path;
  const targetDir = getTargetBaseDir(installPath);
  const targetFolder = aiType === 'all' ? 'claude' : aiType;
  const targetAIFolder = AI_FOLDERS[targetFolder]?.[0] || '.claude';
  const skillsPath = join(targetDir, targetAIFolder, 'skills');

  logger.info(`Installing for: ${chalk.cyan(getAITypeDescription(aiType))}`);
  
  if (options.global) {
    logger.info(`Install mode: ${chalk.cyan('global (~)')}`);
    logger.info(`Target: ${chalk.cyan(skillsPath)}`);
  } else if (options.path) {
    logger.info(`Install mode: ${chalk.cyan('custom path')}`);
    logger.info(`Target: ${chalk.cyan(skillsPath)}`);
  } else {
    logger.info(`Install mode: ${chalk.cyan('current directory')}`);
    logger.info(`Target: ${chalk.cyan(skillsPath)}`);
  }

  const spinner = ora('Installing files...').start();
  let cloudFolders: string[] = [];
  let skillsDirs: string[] = [];
  let installMethod = 'source';

  // Always search for skills relative to current working directory
  const searchDir = process.cwd();

  try {
    // Default: Try GitHub download first, fall back to local source
    if (!options.offline) {
      spinner.text = 'Downloading from GitHub...';
      const githubResult = await tryGitHubInstall(searchDir, provider, spinner);
      if (githubResult && githubResult.length > 0) {
        cloudFolders = githubResult;
        installMethod = 'github';
      }
    }

    // Fall back to local source if GitHub failed or --offline mode
    if (cloudFolders.length === 0) {
      spinner.text = 'Checking local source...';
      const result = await copyFromSource(searchDir, targetDir, provider, aiType, spinner, installPath);
      cloudFolders = result.cloudFolders;
      skillsDirs = result.skillsDirs;
      installMethod = result.cloudFolders.length > 0 ? 'source' : installMethod;
    }

    if (cloudFolders.length === 0) {
      throw new Error('No skill folders found. Try again or check your network.');
    }

    const methodMessage = {
      github: 'Installed from GitHub release!',
      bundled: 'Installed from bundled assets!',
      source: 'Installed from local source!',
    }[installMethod];

    spinner.succeed(methodMessage);

    console.log();
    logger.info('Installed skills:');
    cloudFolders.forEach(folder => {
      console.log(`  ${chalk.green('+')} ${folder}`);
    });

    console.log();
    logger.info('Installation path:');
    skillsDirs.forEach(dir => {
      console.log(`  ${chalk.cyan(dir)}`);
    });

    console.log();
    logger.success('Cloud skills installed successfully!');

    console.log();
    console.log(chalk.bold('Next steps:'));
    console.log(chalk.dim('  1. Restart your AI coding assistant'));
    console.log(chalk.dim('  2. The skill will be automatically loaded'));
    console.log();
  } catch (error) {
    spinner.fail('Installation failed');
    if (error instanceof Error) {
      logger.error(error.message);
    }
    process.exit(1);
  }
}
