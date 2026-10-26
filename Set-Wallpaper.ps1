
# AutoXpress Wallpaper Setup
# The user must run this script and choose whether to enable logon updates.

$ErrorActionPreference = "Stop"
$taskName = "AutoXpress-Wallpaper"
$folder = Join-Path $env:LOCALAPPDATA "AutoXpress"
$scriptPath = Join-Path $folder "Set-Wallpaper.ps1"
$imagePath = Join-Path $folder "wallpaper.jpg"

# Public sample wallpaper. Replace with your approved image URL.
$imageUrl = "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1920&q=85"

function Set-AutoXpressWallpaper {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null

    Invoke-WebRequest -Uri $imageUrl -OutFile $imagePath

    # Confirm the downloaded file is a valid image.
    Add-Type -AssemblyName System.Drawing
    $image = [System.Drawing.Image]::FromFile($imagePath)
    $image.Dispose()

    # Apply wallpaper for the current Windows user.
    Set-ItemProperty `
        -Path "HKCU:\Control Panel\Desktop" `
        -Name Wallpaper `
        -Value $imagePath

    Add-Type @"
using System.Runtime.InteropServices;
public class WallpaperNative {
    [DllImport("user32.dll", SetLastError=true, CharSet=CharSet.Auto)]
    public static extern int SystemParametersInfo(
        int action, int param, string path, int flags
    );
}
"@ -ErrorAction SilentlyContinue

    $result = [WallpaperNative]::SystemParametersInfo(
        20, 0, $imagePath, 3
    )

    if ($result -eq 0) {
        throw "Windows could not apply the wallpaper."
    }

    Write-Host "Wallpaper applied successfully."
}

try {
    Set-AutoXpressWallpaper
}
catch {
    Write-Host "Wallpaper setup failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$choice = Read-Host "Would you like AutoXpress to apply this wallpaper at every sign-in? Type YES or NO"

if ($choice -eq "YES") {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null

    # Save this script locally for the scheduled task.
    Copy-Item -LiteralPath $PSCommandPath -Destination $scriptPath -Force

    $action = New-ScheduledTaskAction `
        -Execute "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" `
        -Argument "-NoProfile -File `"$scriptPath`" -AutoXpressLogon"

    # The task is created only after the user opts in.
    $trigger = New-ScheduledTaskTrigger -AtLogOn

    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Description "User-approved AutoXpress wallpaper task" `
        -Force | Out-Null

    Write-Host "Automatic sign-in task created."
}
else {
    Write-Host "Automatic updates were not enabled."
}
