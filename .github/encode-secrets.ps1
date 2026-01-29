# GitHub Secrets Encoder Script for Windows PowerShell
# Run this script to encode your sensitive files for GitHub Actions

Write-Host "=== GitHub Secrets Encoder ===" -ForegroundColor Cyan
Write-Host ""

$projectRoot = Split-Path -Parent $PSScriptRoot

# Function to encode file and copy to clipboard
function Encode-FileToBase64 {
    param(
        [string]$filePath,
        [string]$secretName
    )
    
    $fullPath = Join-Path $projectRoot $filePath
    
    if (Test-Path $fullPath) {
        try {
            $base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($fullPath))
            $base64 | Set-Clipboard
            Write-Host "✓ Encoded: $secretName" -ForegroundColor Green
            Write-Host "  File: $filePath" -ForegroundColor Gray
            Write-Host "  Length: $($base64.Length) characters" -ForegroundColor Gray
            Write-Host "  Status: COPIED TO CLIPBOARD" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  → Now go to GitHub → Settings → Secrets → Actions" -ForegroundColor Cyan
            Write-Host "  → Create new secret named: $secretName" -ForegroundColor Cyan
            Write-Host "  → Paste from clipboard (Ctrl+V)" -ForegroundColor Cyan
            Write-Host ""
            
            # Wait for user confirmation
            Read-Host "Press Enter after you've added '$secretName' to GitHub Secrets"
            return $true
        }
        catch {
            Write-Host "✗ Error encoding $filePath : $_" -ForegroundColor Red
            return $false
        }
    }
    else {
        Write-Host "✗ File not found: $fullPath" -ForegroundColor Red
        Write-Host "  Please ensure this file exists before running the script." -ForegroundColor Yellow
        return $false
    }
}

# Encode google-services.json
Write-Host "1/2 Encoding google-services.json..." -ForegroundColor Cyan
$success1 = Encode-FileToBase64 -filePath "android\app\google-services.json" -secretName "GOOGLE_SERVICES_JSON"

# Encode firebase_options.dart
Write-Host "2/2 Encoding firebase_options.dart..." -ForegroundColor Cyan
$success2 = Encode-FileToBase64 -filePath "lib\firebase_options.dart" -secretName "FIREBASE_OPTIONS_DART"

# Summary
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
if ($success1 -and $success2) {
    Write-Host "✓ All files encoded successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Make sure you've added all secrets to GitHub" -ForegroundColor White
    Write-Host "2. Go to Actions tab and re-run your workflow" -ForegroundColor White
    Write-Host "3. The CI/CD should now pass!" -ForegroundColor White
}
else {
    Write-Host "⚠ Some files could not be encoded" -ForegroundColor Yellow
    Write-Host "Please check the errors above and try again" -ForegroundColor White
}

Write-Host ""
Read-Host "Press Enter to exit"
