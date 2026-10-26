# AutoXpress - Online Wallpaper Setup
$ImageUrl = "https://example.com/wallpaper.jpg"

$WallpaperFolder = Join-Path $env:LOCALAPPDATA "AutoXpress"
$WallpaperPath = Join-Path $WallpaperFolder "wallpaper.jpg"

try {
    # Only allow HTTPS image links
    $Uri = [System.Uri]$ImageUrl
    if ($Uri.Scheme -ne "https") {
        throw "Please use a secure HTTPS image URL."
    }

    # Create local folder
    New-Item -ItemType Directory -Path $WallpaperFolder -Force |
        Out-Null

    # Download image
    Invoke-WebRequest -Uri $ImageUrl `
        -OutFile $WallpaperPath `
        -UseBasicParsing `
        -TimeoutSec 30

    # Verify that the downloaded file is an image
    Add-Type -AssemblyName System.Drawing
    $Image = [System.Drawing.Image]::FromFile($WallpaperPath)
    $Image.Dispose()

    # Apply wallpaper for the current Windows user
    Add-Type @"
using System.Runtime.InteropServices;

public class WallpaperSetter {
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern bool SystemParametersInfo(
        int action, int param, string image, int flags);
}
"@

    $Success = [WallpaperSetter]::SystemParametersInfo(
        20, 0, $WallpaperPath, 3
    )

    if (-not $Success) {
        throw "Windows could not apply the wallpaper."
    }

    Write-Host "Wallpaper updated successfully." -ForegroundColor Green
}
catch {
    Write-Host "Wallpaper update failed: $($_.Exception.Message)" `
        -ForegroundColor Red
}
