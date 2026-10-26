
$ErrorActionPreference = "Stop"

$taskName = "AutoXpress-Wallpaper"
$folder = Join-Path $env:LOCALAPPDATA "AutoXpress"
$imagePath = Join-Path $folder "wallpaper.jpg"
$scriptPath = Join-Path $folder "Set-Wallpaper.ps1"

$imageUrl = "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=1920&q=85"

New-Item -ItemType Directory -Path $folder -Force | Out-Null

function Set-AutoXpressWallpaper {
    Invoke-WebRequest -Uri $imageUrl -OutFile $imagePath

    Add-Type -AssemblyName System.Drawing
    $img = [System.Drawing.Image]::FromFile($imagePath)
    $img.Dispose()

    Add-Type @"
using System.Runtime.InteropServices;
public class AutoXpressWallpaper {
    [DllImport("user32.dll", CharSet=CharSet.Auto, SetLastError=true)]
    public static extern bool SystemParametersInfo(
        int action, int param, string path, int flags
    );
}
"@

    $ok = [AutoXpressWallpaper]::SystemParametersInfo(
        20, 0, $imagePath, 3
    )

    if (-not $ok) {
        throw "Windows could not set the wallpaper."
    }
}

try {
    Set-AutoXpressWallpaper
    Write-Host "Wallpaper applied successfully."
}
catch {
    Write-Host "Could not apply wallpaper: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# A scheduled run only applies the wallpaper; it does not ask again.
if ($args -contains "--logon") {
    exit 0
}

$choice = Read-Host "Enable automatic wallpaper changes at sign-in? Type YES to agree"

if ($choice -ceq "YES") {
    Copy-Item -LiteralPath $PSCommandPath -Destination $scriptPath -Force

    $powershell = Join-Path $env:SystemRoot "System32\WindowsPowerShell\v1.0\powershell.exe"
    $action = New-ScheduledTaskAction `
        -Execute $powershell `
        -Argument "-NoProfile -File `"$scriptPath`" --logon"

    $trigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"

    Register-ScheduledTask `
        -TaskName $taskName `
        -Action $action `
        -Trigger $trigger `
        -Description "User-approved AutoXpress wallpaper at sign-in" `
        -Force | Out-Null

    Write-Host "Automatic wallpaper task enabled for your account."
}
else {
    Write-Host "Automatic changes were not enabled."
}
