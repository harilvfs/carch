#!/usr/bin/env node

const { execSync } = require('child_process');
const fs = require('fs');

// Configuration for commit types and their corresponding emoji/category
const COMMIT_TYPES = {
  feat: { emoji: '🚀', title: 'Features' },
  fix: { emoji: '🐛', title: 'Bug Fixes' },
  docs: { emoji: '📖', title: 'Documentation' },
  style: { emoji: '🎨', title: 'Styling' },
  refactor: { emoji: '🔄', title: 'Refactoring' },
  perf: { emoji: '⚡', title: 'Performance' },
  test: { emoji: '🧪', title: 'Tests' },
  build: { emoji: '🛠️', title: 'Build' },
  ci: { emoji: '⚙️', title: 'CI/CD' },
  chore: { emoji: '🧰', title: 'Chores' },
  revert: { emoji: '↩️', title: 'Reverts' },
  init: { emoji: '🎬', title: 'Initial' },
  wip: { emoji: '🚧', title: 'Work In Progress' },
  security: { emoji: '🔒', title: 'Security' },
  infra: { emoji: '🏗️', title: 'Infrastructure' },
  db: { emoji: '🗃️', title: 'Database' },
  rust: { emoji: '🦀', title: 'Rust' },
  breaking: { emoji: '💥', title: 'Breaking Changes' }
};

// Helper function to get tag name
function getLatestTag() {
  try {
    return execSync('git describe --tags --abbrev=0').toString().trim();
  } catch (error) {
    return null;
  }
}

// Get all commits since last tag or from beginning if no tags
function getCommits() {
  const latestTag = getLatestTag();
  const range = latestTag ? `${latestTag}..HEAD` : '';
  
  // Format: hash|author|date|subject
  const command = `git log ${range} --pretty=format:"%h|%an|%ad|%s" --date=short`;
  const output = execSync(command).toString().trim();
  
  if (!output) return [];
  
  return output.split('\n').map(line => {
    const [hash, author, date, subject] = line.split('|');
    return { hash, author, date, subject };
  });
}

// Parse commit messages to categorize them
function categorizeCommits(commits) {
  const categories = {};
  
  // Initialize categories
  Object.keys(COMMIT_TYPES).forEach(type => {
    categories[type] = [];
  });
  
  // Special category for uncategorized commits
  categories.other = [];
  
  // Breaking changes category
  categories.breaking = [];
  
  commits.forEach(commit => {
    const { hash, author, date, subject } = commit;
    
    // Check for breaking changes (with ! or BREAKING prefix)
    if (subject.includes('BREAKING CHANGE:') || subject.includes('BREAKING:') || 
        /^(\w+)!:/.test(subject)) {
      categories.breaking.push({ hash, author, date, subject });
      return;
    }
    
    // Try to match conventional commit format: type(scope): message
    const match = subject.match(/^(\w+)(\([\w-]+\))?:\s*(.+)$/);
    
    if (match) {
      const [, type, , message] = match;
      if (categories[type]) {
        categories[type].push({ hash, author, date, subject });
      } else {
        categories.other.push({ hash, author, date, subject });
      }
    } else {
      categories.other.push({ hash, author, date, subject });
    }
  });
  
  return categories;
}

// Generate markdown for release notes
function generateReleaseNotes(categories) {
  let markdown = '# Release Notes\n\n';
  
  // Add breaking changes first if any
  if (categories.breaking.length > 0) {
    markdown += `## ${COMMIT_TYPES.breaking.emoji} ${COMMIT_TYPES.breaking.title}\n\n`;
    categories.breaking.forEach(commit => {
      markdown += `- ${commit.subject} ([${commit.hash}](https://github.com/OWNER/REPO/commit/${commit.hash})) - ${commit.author}\n`;
    });
    markdown += '\n';
  }
  
  // Add other categories
  Object.keys(COMMIT_TYPES).forEach(type => {
    if (type !== 'breaking' && categories[type] && categories[type].length > 0) {
      markdown += `## ${COMMIT_TYPES[type].emoji} ${COMMIT_TYPES[type].title}\n\n`;
      
      categories[type].forEach(commit => {
        markdown += `- ${commit.subject} ([${commit.hash}](https://github.com/OWNER/REPO/commit/${commit.hash})) - ${commit.author}\n`;
      });
      
      markdown += '\n';
    }
  });
  
  // Add uncategorized commits if any
  if (categories.other.length > 0) {
    markdown += `## 📋 Other Changes\n\n`;
    categories.other.forEach(commit => {
      markdown += `- ${commit.subject} ([${commit.hash}](https://github.com/OWNER/REPO/commit/${commit.hash})) - ${commit.author}\n`;
    });
    markdown += '\n';
  }
  
  return markdown;
}

// Main function
function main() {
  console.log('Generating release notes from conventional commits...');
  
  const commits = getCommits();
  const categories = categorizeCommits(commits);
  const releaseNotes = generateReleaseNotes(categories);
  
  // Write to file
  fs.writeFileSync('RELEASE_NOTES.md', releaseNotes);
  
  console.log('Release notes generated successfully and saved to RELEASE_NOTES.md');
}

main();
