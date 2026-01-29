# Fix Base64 Secret Issues in GitHub CI/CD

## Problem
You're seeing this error in GitHub Actions:
```
base64: invalid input
Error: Process completed with exit code 1.
```

## Root Cause
The GitHub secret `GOOGLE_SERVICES_JSON` (and possibly `FIREBASE_OPTIONS_DART`) is either:
1. **Not set** in your GitHub repository secrets
2. **Not properly base64-encoded**

## Solution Steps

### Step 1: Encode Your Files to Base64

You need to encode your sensitive files to base64 **without line breaks**.

#### On Windows (PowerShell):
```powershell
# For google-services.json
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android\app\google-services.json")) | Set-Clipboard
# Now paste from clipboard to GitHub secrets

# For firebase_options.dart
[Convert]::ToBase64String([IO.File]::ReadAllBytes("lib\firebase_options.dart")) | Set-Clipboard
# Now paste from clipboard to GitHub secrets
```

#### On Windows (Git Bash):
```bash
# For google-services.json
base64 -w 0 android/app/google-services.json
# Copy the output

# For firebase_options.dart
base64 -w 0 lib/firebase_options.dart
# Copy the output
```

#### On Linux/macOS:
```bash
# For google-services.json
base64 -w 0 android/app/google-services.json
# or on macOS:
base64 -i android/app/google-services.json | tr -d '\n'

# For firebase_options.dart
base64 -w 0 lib/firebase_options.dart
# or on macOS:
base64 -i lib/firebase_options.dart | tr -d '\n'
```

### Step 2: Add Secrets to GitHub

1. Go to your GitHub repository
2. Click **Settings** (top menu)
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add these secrets:

   | Secret Name | Value |
   |-------------|-------|
   | `GOOGLE_SERVICES_JSON` | The base64-encoded content of `android/app/google-services.json` |
   | `FIREBASE_OPTIONS_DART` | The base64-encoded content of `lib/firebase_options.dart` |
   | `GEMINI_API_KEY` | Your Gemini API key |
   | `STABILITY_API_KEY` | Your Stability AI API key |
   | `REMOVEBG_API_KEY` | Your Remove.bg API key |
   | `HF_TOKEN` | Your Hugging Face token |
   | `HUGGINGFACE_API_KEY` | Your Hugging Face API key |

### Step 3: Verify the Secrets

To verify the encoding is correct, you can test locally:

```bash
# Test decoding google-services.json
echo "YOUR_BASE64_STRING_HERE" | base64 --decode > test-google-services.json
cat test-google-services.json
# Should show valid JSON content

# Clean up test file
rm test-google-services.json
```

### Step 4: Common Mistakes to Avoid

❌ **Don't do this:**
- Copy the file with line breaks in the base64
- Forget to remove trailing newlines
- Add quotes around the base64 string in GitHub secrets

✅ **Do this:**
- Encode the entire file as a single line of base64
- Copy the exact output without modifications
- Paste directly into GitHub secrets (no quotes needed)

### Step 5: Re-run the Workflow

After adding the secrets:
1. Go to **Actions** tab in your repository
2. Select the failed workflow run
3. Click **Re-run all jobs**

## Troubleshooting

### Issue: "Context access might be invalid"
This is just a warning from GitHub. It appears when:
- The secret hasn't been created yet
- The workflow file references a secret name

**Solution:** Ignore this warning once you've added the secret to your repository.

### Issue: Still getting "invalid input" after adding secrets
**Possible causes:**
1. The base64 string has line breaks (must be single line)
2. You accidentally added quotes or spaces
3. The original file is corrupted

**Solution:** Re-encode the file using the commands above and ensure you copy the **entire** output as a **single line**.

### Issue: Workflow passes but app crashes
**Possible causes:**
- The decoded file is not valid JSON/Dart
- The base64 was incomplete

**Solution:** Test decoding locally first before adding to GitHub.

## Quick Commands Reference

### Encode (choose your OS):
```bash
# PowerShell (Windows) - copies to clipboard
[Convert]::ToBase64String([IO.File]::ReadAllBytes("path/to/file")) | Set-Clipboard

# Git Bash / Linux (prints to terminal)
base64 -w 0 path/to/file

# macOS (prints to terminal)
base64 -i path/to/file | tr -d '\n'
```

### Decode (for testing):
```bash
echo "BASE64_STRING" | base64 --decode > output.txt
```
