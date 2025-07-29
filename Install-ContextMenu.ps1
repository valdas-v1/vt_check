Write-Host "Installing VirusTotal context menu..." -ForegroundColor Cyan

# Get the directory where this script is located
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$checkScript = Join-Path $scriptDir "Check-VirusTotal.ps1"
$vbsScript = Join-Path $scriptDir "run-silent.vbs"

# Verify the main script exists
if (-not (Test-Path $checkScript)) {
    Write-Error "Check-VirusTotal.ps1 not found in script directory: $scriptDir"
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

# Create the VBScript wrapper for silent execution
$vbsContent = @"
CreateObject("Wscript.Shell").Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & "$checkScript" & """ -FilePath """ & WScript.Arguments(0) & """", 0, False
"@

Set-Content -Path $vbsScript -Value $vbsContent -Encoding ASCII

# Registry path for context menu
$regPath = "HKCU:\Software\Classes\*\shell\VirusTotalCheck"
$commandPath = "$regPath\command"

try {
    # Create registry keys for context menu
    New-Item -Path $regPath -Force | Out-Null
    New-Item -Path $commandPath -Force | Out-Null
    
    # Set the display name and command
    $magnifyingGlassIcon = "shell32.dll,22"  # Magnifying glass icon from shell32.dll
    & reg add "HKCU\Software\Classes\*\shell\VirusTotalCheck" /ve /d "Check on VirusTotal" /f | Out-Null
    & reg add "HKCU\Software\Classes\*\shell\VirusTotalCheck" /v "Icon" /d $magnifyingGlassIcon /f | Out-Null
    $command = "wscript.exe `"$vbsScript`" `"%1`""
    & reg add "HKCU\Software\Classes\*\shell\VirusTotalCheck\command" /ve /d $command /f | Out-Null
    
    Write-Host "Context menu successfully installed!" -ForegroundColor Green
    Write-Host "Right-click any file and select 'Check on VirusTotal'" -ForegroundColor Yellow
    Write-Host "(On Windows 11, look in 'Show more options')" -ForegroundColor Gray
    
    # Refresh the shell icon cache (much gentler than restarting Explorer)
    Write-Host "Refreshing context menu cache..." -ForegroundColor Cyan
    & ie4uinit.exe -show | Out-Null
}
catch {
    Write-Error "Failed to install context menu: $_"
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
