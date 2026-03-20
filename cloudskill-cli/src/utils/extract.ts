import { mkdir, readdir, copyFile, rm } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import type { CloudProvider } from '../types/index.js';
import { CLOUD_FOLDERS } from '../types/index.js';

export async function createTempDir(): Promise<string> {
  const tmpDir = join(process.env.TMPDIR || '/tmp', `cloudskill-${Date.now()}`);
  await mkdir(tmpDir, { recursive: true });
  return tmpDir;
}

export async function cleanup(dir: string): Promise<void> {
  try {
    await rm(dir, { recursive: true, force: true });
  } catch {
    // Ignore cleanup errors
  }
}

export async function copyFolders(
  sourceDir: string,
  targetDir: string,
  provider: CloudProvider
): Promise<string[]> {
  const folders = provider === 'all'
    ? ['alibaba-cloud-skill', 'aws-cloud-skill']
    : CLOUD_FOLDERS[provider];

  if (!folders) {
    return [];
  }

  const copiedFolders: string[] = [];

  for (const folder of folders) {
    const src = join(sourceDir, folder);
    const dest = join(targetDir, folder);

    try {
      await copyFileRecursive(src, dest);
      copiedFolders.push(folder);
    } catch (error) {
      // Skip folders that don't exist in bundled assets
      continue;
    }
  }

  return copiedFolders;
}

async function copyFileRecursive(src: string, dest: string): Promise<void> {
  const { stat, copyFile, mkdir, readdir } = await import('node:fs/promises');
  const srcStat = await stat(src);

  if (srcStat.isDirectory()) {
    await mkdir(dest, { recursive: true });
    const entries = await readdir(src);

    for (const entry of entries) {
      await copyFileRecursive(join(src, entry), join(dest, entry));
    }
  } else {
    await mkdir(dirname(dest), { recursive: true });
    await copyFile(src, dest);
  }
}

export async function installFromZip(
  zipPath: string,
  targetDir: string,
  provider: CloudProvider
): Promise<{ copiedFolders: string[]; tempDir: string }> {
  const tempDir = await createTempDir();

  const copiedFolders = await copyFolders(tempDir, targetDir, provider);

  return { copiedFolders, tempDir };
}
