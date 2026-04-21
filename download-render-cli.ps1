# download-render-cli.ps1
# Downloads the official Render CLI for Windows (x86_64)
# Run with: powershell -ExecutionPolicy Bypass -File download-render-cli.ps1

$ErrorActionPreference = "Stop"

Write-Host "Fetching latest Render CLI release..." -ForegroundColor Cyan

$releaseUrl = "https://api.github.com/repos/render-oss/cli/releases/latest"
$release = Invoke-RestMethod -Uri $releaseUrl -Headers @{ "User-Agent" = "spendwise-setup" }
$version = $release.tag_name

Write-Host "Latest version: $version" -ForegroundColor Green

# Find the Windows AMD64 asset
$asset = $release.assets | Where-Object { $_.name -like "*windows*amd64*" -or $_.name -like "*windows*x86_64*" }

if (-not $asset) {
    Write-Host "Could not auto-detect Windows asset. Available assets:" -ForegroundColor Yellow
    $release.assets | ForEach-Object { Write-Host "  $($_.name)" }
    Write-Host ""
    Write-Host "Please download manually from: https://github.com/render-oss/cli/releases/latest" -ForegroundColor Yellow
    exit 1
}

$downloadUrl = $asset.browser_download_url
$outputFile = "render-cli.exe"

Write-Host "Downloading from: $downloadUrl" -ForegroundColor Cyan
Invoke-WebRequest -Uri $downloadUrl -OutFile $outputFile

Write-Host ""
Write-Host "SUCCESS! Render CLI downloaded as '$outputFile'" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Move render-cli.exe to a folder in your PATH (e.g. C:\Windows\System32\), or" -ForegroundColor White
Write-Host "     run it from this folder as: .\render-cli.exe" -ForegroundColor White
Write-Host "  2. Login to Render:" -ForegroundColor White
Write-Host "     .\render-cli.exe login" -ForegroundColor Cyan
Write-Host "  3. Deploy using the render.yaml blueprint via the Render dashboard." -ForegroundColor White
