import chalk from 'chalk';
import ora from 'ora';
import { exec } from 'node:child_process';
import { logger } from '../utils/logger.js';
import { initCommand } from './init.js';
import type { CloudProvider, AIType } from '../types/index.js';

const REPO_URL = 'https://github.com/RupengWang/awsome-cloud-skills.git';

interface UpdateOptions {
  provider?: CloudProvider;
  ai?: AIType;
}

export async function updateCommand(options: UpdateOptions): Promise<void> {
  logger.title('Cloud Skills Updater');

  const spinner = ora('Checking for updates...').start();

  try {
    // Check if we can connect to GitHub
    await new Promise<void>((resolve, reject) => {
      exec(`git ls-remote --heads "${REPO_URL}"`, (error) => {
        if (error) {
          reject(error);
        } else {
          resolve();
        }
      });
    });
    
    spinner.succeed('GitHub connection successful');

    console.log();
    logger.info('Running update (pulling latest from GitHub)...');
    console.log();

    await initCommand({
      provider: options.provider,
      ai: options.ai,
      force: true,
    });
  } catch (error) {
    spinner.fail('Update check failed');
    if (error instanceof Error) {
      logger.error(error.message);
    }
    process.exit(1);
  }
}
