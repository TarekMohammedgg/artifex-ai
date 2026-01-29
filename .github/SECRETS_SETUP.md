# GitHub Secrets Setup Guide

This guide will help you configure the required GitHub secrets for the CI/CD workflow.

## 📋 Required Secrets

You need to add the following secrets to your GitHub repository:

### 1. API Keys (from .env file)

Go to your repository on GitHub → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add each of the following secrets:

| Secret Name | Description | Current Value (DON'T COMMIT THIS FILE!) |
|-------------|-------------|----------------------------------------|
| `GEMINI_API_KEY` | Google Gemini API Key | Your API key |
| `STABILITY_API_KEY` | Stability AI API Key | Your API key |
| `REMOVEBG_API_KEY` | Remove.bg API Key | Your API key |
| `HF_TOKEN` | Hugging Face Token | Your token |
| `HUGGINGFACE_API_KEY` | Hugging Face API Key | Your API key |

### 2. Firebase Configuration Files

These files need to be **base64 encoded** before adding to GitHub secrets.

#### On Windows (PowerShell):

```powershell
# For GOOGLE_SERVICES_JSON
$content = Get-Content "android\app\google-services.json" -Raw
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content))

# For FIREBASE_OPTIONS_DART
$content = Get-Content "lib\firebase_options.dart" -Raw
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($content))
```

#### On Linux/Mac:

```bash
# For GOOGLE_SERVICES_JSON
base64 android/app/google-services.json | tr -d '\n'

# For FIREBASE_OPTIONS_DART
base64 lib/firebase_options.dart | tr -d '\n'
```

Then add these to GitHub secrets:

| Secret Name | File to Encode |
|-------------|----------------|
| `GOOGLE_SERVICES_JSON` | `android/app/google-services.json` |
| `FIREBASE_OPTIONS_DART` | `lib/firebase_options.dart` |

## ⚠️ Security Notes

1. **NEVER commit this file with actual API keys to GitHub**
2. Add `SECRETS_SETUP.md` to `.gitignore` if you fill in the values
3. Keep your API keys private and rotate them if exposed
4. Use GitHub's secret scanning to detect exposed secrets

## ✅ Verification

After setting up all secrets:

1. Go to Actions tab in your repository
2. Push a commit or create a pull request
3. Watch the workflow run
4. Check if all steps complete successfully

## 🔄 Updating Secrets

To update a secret:
1. Go to repository **Settings** → **Secrets and variables** → **Actions**
2. Click on the secret name
3. Click **Update secret**
4. Enter the new value

## 📝 Quick Setup Checklist

- [ ] Added `GEMINI_API_KEY`
- [ ] Added `STABILITY_API_KEY`
- [ ] Added `REMOVEBG_API_KEY`
- [ ] Added `HF_TOKEN`
- [ ] Added `HUGGINGFACE_API_KEY`
- [ ] Encoded and added `GOOGLE_SERVICES_JSON`
- [ ] Encoded and added `FIREBASE_OPTIONS_DART`
- [ ] Tested workflow by pushing to main branch
