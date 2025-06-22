# Release Guide - Version 1.1.0

This guide provides the Git Flow commands to prepare and complete the release 1.1.0.

## Simplified Workflow Structure

We now have a **streamlined workflow setup**:

- **`ci.yaml`**: Runs tests and analysis on `main`/`develop` pushes
- **`publish.yaml`**: Publishes to pub.dev and creates GitHub Release on tags
- **`security_scan.yaml`**: Monthly security scans (first Monday of each month)
- **`dependabot.yml`**: Monthly dependency updates

## Pre-Release Checklist

✅ **Completed**:
- [x] CHANGELOG.md updated with version 1.1.0
- [x] pubspec.yaml version updated to 1.1.0
- [x] All features merged to develop
- [x] Tests passing
- [x] Documentation updated
- [x] Workflow structure simplified

## Git Flow Release Commands

### Option 1: Using Standard Git Commands

```bash
# 1. Ensure you're on develop and it's up to date
git checkout develop
git pull origin develop

# 2. Create release branch
git checkout -b release/1.1.0

# 3. Commit final changes
git add .
git commit -m "chore(release): prepare version 1.1.0

- Updated CHANGELOG.md with 1.1.0 features
- Bumped version to 1.1.0 in pubspec.yaml
- Simplified workflow structure
- Removed example app builds from CI
- Set Dependabot and security scans to monthly"

# 4. Push release branch
git push -u origin release/1.1.0

# 5. Create Pull Request to main
# - Title: "Release 1.1.0"
# - Description: Include changelog entries

# 6. After PR approval, merge to main
git checkout main
git pull origin main
git merge release/1.1.0

# 7. Create and push tag (this triggers publish.yaml)
git tag -a v1.1.0 -m "Release version 1.1.0

Simplified Workflow & Configuration Updates

### Added
- Streamlined CI/CD with only essential workflows
- Monthly security scans and dependency updates
- Git Flow integration with comprehensive documentation

### Changed  
- Removed example app builds from CI workflows
- Simplified workflow structure (3 workflows instead of 7)
- Monthly schedule for Dependabot and security scans

### Removed
- Complex multi-job workflows
- Unnecessary build validations
- Feature branch validation workflows"

git push origin v1.1.0

# 8. Merge back to develop
git checkout develop
git pull origin develop
git merge main
git push origin develop

# 9. Clean up release branch
git branch -d release/1.1.0
git push origin --delete release/1.1.0
```

### Option 2: Using Git Flow Extension

```bash
# 1. Initialize Git Flow (if not already done)
git flow init -d

# 2. Start release
git flow release start 1.1.0

# 3. Commit changes
git add .
git commit -m "chore(release): prepare version 1.1.0

- Updated CHANGELOG.md with 1.1.0 features
- Bumped version to 1.1.0 in pubspec.yaml
- Simplified workflow structure
- Removed example app builds from CI
- Set Dependabot and security scans to monthly"

# 4. Finish release (merges to main and develop, creates tag)
git flow release finish 1.1.0

# 5. Push all branches and tags
git push origin main
git push origin develop
git push origin --tags
```

## What Happens After Tag Push

When you push the `v1.1.0` tag:

1. **🤖 `publish.yaml` workflow triggers automatically**
2. **🧪 Runs tests** to ensure quality
3. **📋 Validates package** with `pub publish --dry-run`
4. **🚀 Publishes to pub.dev** automatically
5. **🏷️ Creates GitHub Release** with changelog notes

## Simplified Workflow Benefits

### Before (7 workflows):
- `test_analyze_coverage.yaml` ❌
- `publish_pub_dev.yaml` ❌
- `feature_validation.yaml` ❌
- `release_production.yaml` ❌
- `security_scan.yaml` ✅
- `ci.yaml` ✅ (new)
- `publish.yaml` ✅ (new)

### After (3 workflows):
- **`ci.yaml`**: Test & analyze on main/develop
- **`publish.yaml`**: Publish on tags
- **`security_scan.yaml`**: Monthly security audit

### Key Improvements:
- ⚡ **Faster CI**: Single job instead of multiple parallel jobs
- 🎯 **Focused**: Only essential validations
- 📅 **Monthly maintenance**: Dependabot and security scans
- 🚫 **No example builds**: Removed unnecessary example app compilation
- 🔄 **Simpler maintenance**: 3 workflows instead of 7

## Monthly Automation

- **First Monday of each month**: Security scan runs automatically
- **Monthly**: Dependabot creates PRs for dependency updates
- **On tag push**: Automatic publication to pub.dev

## Troubleshooting

### If publication fails:
1. Check that `PUB_DEV_CREDENTIALS` secret is set
2. Verify tests pass in the publish workflow
3. Ensure CHANGELOG.md contains the version

### If Git Flow Extension is not installed:
```bash
# On macOS with Homebrew
brew install git-flow

# On Ubuntu/Debian
sudo apt-get install git-flow

# On Windows with Git Bash
# Download from: https://github.com/nvie/gitflow/wiki/Windows
```

---

**Ready to release?** The workflow is now much simpler - just push the tag and everything happens automatically! 