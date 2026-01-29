# ⚠️ CRITICAL: Remove Sensitive Files from Git

## Problem
Your sensitive files (`google-services.json` and `firebase_options.dart`) are currently tracked by Git, which means they're in your repository history and potentially exposed on GitHub.

## Solution
Follow these steps to remove them from Git while keeping them locally:

### Step 1: Remove Files from Git Tracking (Keep Locally)

Run these commands in PowerShell or CMD:

```bash
# Navigate to your project directory
cd e:\root\Programming\mobile-development\flutter_projects\ai_chatbot

# Remove files from Git tracking (but keep them locally)
git rm --cached android/app/google-services.json
git rm --cached lib/firebase_options.dart

# If .env is also tracked (though it might not be), remove it too:
git rm --cached .env
```

### Step 2: Commit the Changes

```bash
git add .gitignore
git commit -m "Remove sensitive files from Git tracking"
```

### Step 3: Push to GitHub

```bash
git push origin main
```

## Verification

After pushing, verify that:

1. **Files are still on your local machine** ✅
2. **Files are no longer tracked by Git**:
   ```bash
   git ls-files | findstr /I "google-services firebase_options .env"
   ```
   This should only show:
   - `.env.example` (OK)
   - `lib/core/env.dart` (OK)

3. **Files will be recreated by CI/CD** from GitHub secrets ✅

## Security Note

⚠️ **The files are still in Git history!** If your repository is public or you want to completely remove them from history, you'll need to use `git filter-branch` or `BFG Repo-Cleaner`. However, the immediate fix above prevents future commits from including these files.

## What Happens Next?

### Local Development (Your Computer)
- ✅ You keep all files locally
- ✅ You can run and test your app normally
- ✅ Git ignores changes to these files

### CI/CD (GitHub Actions)
- ✅ Workflow creates `.env` from your GitHub secrets
- ✅ Workflow creates `google-services.json` from secrets
- ✅ Workflow creates `firebase_options.dart` from secrets
- ✅ Builds and tests run successfully

## Quick Checklist

- [ ] Run `git rm --cached` commands above
- [ ] Commit the changes
- [ ] Push to GitHub
- [ ] Verify files are still on your local machine
- [ ] Verify files are no longer tracked by Git
- [ ] Set up GitHub secrets (as per SECRETS_SETUP.md)
- [ ] Test the CI/CD workflow

## Questions?

If you need to completely purge these files from Git history (recommended if your repo is public):
1. Consider using [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
2. Or manually rotate all your API keys and Firebase config
