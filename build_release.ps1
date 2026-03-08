# ============================================================================
# build_release.ps1
#
# Usage:
#   .\build_release.ps1              → auto-increments build number, then builds
#   .\build_release.ps1 -Version "2.0.0"   → sets version name manually, resets build to 1
#   .\build_release.ps1 -Version "2.0.0" -Build 5  → sets both manually
#
# Examples:
#   .\build_release.ps1                    →  1.0.0+1  becomes  1.0.0+2
#   .\build_release.ps1 -Version "1.1.0"   →  1.1.0+1
#   .\build_release.ps1 -Version "1.1.0" -Build 10  →  1.1.0+10
# ============================================================================

param (
    [string]$Version = "",
    [int]$Build = -1
)

$pubspec = "pubspec.yaml"

if (-not (Test-Path $pubspec)) {
    Write-Error "pubspec.yaml not found. Run this script from the project root."
    exit 1
}

# Read current version line  e.g.  version: 1.0.0+5
$content = Get-Content $pubspec -Raw
if ($content -notmatch 'version:\s*(\d+\.\d+\.\d+)\+(\d+)') {
    Write-Error "Could not parse version from pubspec.yaml. Expected format: version: x.y.z+n"
    exit 1
}

$currentVersionName = $Matches[1]   # e.g. "1.0.0"
$currentBuildNumber = [int]$Matches[2]  # e.g. 1

# Determine new values
$newVersionName = if ($Version -ne "") { $Version } else { $currentVersionName }
$newBuildNumber = if ($Build -ge 0) {
    $Build
} elseif ($Version -ne "") {
    1   # reset build to 1 when bumping version name manually
} else {
    $currentBuildNumber + 1   # auto-increment
}

$newVersionFull = "$newVersionName+$newBuildNumber"

# Update pubspec.yaml
$updated = $content -replace 'version:\s*\d+\.\d+\.\d+\+\d+', "version: $newVersionFull"
Set-Content $pubspec $updated -NoNewline

Write-Host ""
Write-Host "Version bumped: $currentVersionName+$currentBuildNumber  →  $newVersionFull" -ForegroundColor Green
Write-Host "Building release APK..." -ForegroundColor Cyan
Write-Host ""

flutter build apk --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Build successful!  v$newVersionFull" -ForegroundColor Green
    Write-Host "APK: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "Build failed. Version in pubspec.yaml has already been updated to $newVersionFull." -ForegroundColor Red
}
