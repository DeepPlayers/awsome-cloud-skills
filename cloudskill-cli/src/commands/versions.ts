import chalk from 'chalk';
import ora from 'ora';
import { exec } from 'node:child_process';
import { logger } from '../utils/logger.js';

const REPO_URL = 'https://github.com/RupengWang/awsome-cloud-skills.git';

export async function versionsCommand(): Promise<void> {
  const spinner = ora('Fetching tags...').start();

  try {
    const result = await new Promise<string>((resolve, reject) => {
      exec(`git ls-remote --tags "${REPO_URL}"`, (error, stdout, stderr) => {
        if (error) {
          reject(new Error(stderr || error.message));
        } else {
          resolve(stdout);
        }
      });
    });

    const tags = result
      .split('\n')
      .filter(line => line.includes('refs/tags/'))
      .map(line => {
        const parts = line.split('\t');
        const ref = parts[1] || '';
        return ref.replace('refs/tags/', '').replace('^{}', '');
      })
      .filter(tag => tag && !tag.includes('^{}'));

    if (tags.length === 0) {
      spinner.warn('No tags found');
      return;
    }

    spinner.succeed(`Found ${tags.length} tag(s)\n`);

    console.log(chalk.bold('Available tags:\n'));

    tags.slice(0, 10).forEach((tag, index) => {
      const isLatest = index === 0;
      if (isLatest) {
        console.log(`  ${chalk.green('*')} ${chalk.bold(tag)} ${chalk.green('[latest]')}`);
      } else {
        console.log(`    ${tag}`);
      }
    });

    if (tags.length > 10) {
      console.log(chalk.dim(`    ... and ${tags.length - 10} more`));
    }

    console.log();
    logger.dim('Use: cloudskill init to install from main branch');
  } catch (error) {
    spinner.fail('Failed to fetch tags');
    if (error instanceof Error) {
      logger.error(error.message);
    }
    process.exit(1);
  }
}
