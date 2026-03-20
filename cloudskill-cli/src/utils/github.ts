import { exec } from 'node:child_process';
import { join } from 'node:path';

const REPO_URL = 'https://github.com/RupengWang/awsome-cloud-skills.git';

export class GitCloneError extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'GitCloneError';
  }
}

/**
 * Clone the repository to a temporary directory
 */
export async function cloneRepo(destDir: string): Promise<string> {
  return new Promise((resolve, reject) => {
    exec(`git clone "${REPO_URL}" "${destDir}" --depth 1`, (error, stdout, stderr) => {
      if (error) {
        reject(new GitCloneError(`Failed to clone repository: ${stderr || error.message}`));
      } else {
        resolve(destDir);
      }
    });
  });
}
