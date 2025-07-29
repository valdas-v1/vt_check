Write-Host "Removing VirusTotal context menu..." -ForegroundColor Cyan

try {
    # Check if the registry key exists using reg.exe
    $result = & reg query "HKCU\Software\Classes\*\shell\VirusTotalCheck" 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        # Key exists, remove it
        & reg delete "HKCU\Software\Classes\*\shell\VirusTotalCheck" /f | Out-Null
        
        # Also remove the VBScript file if it exists
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
        $vbsScript = Join-Path $scriptDir "run-silent.vbs"
        if (Test-Path $vbsScript) {
            Remove-Item $vbsScript -Force
        }
        
        Write-Host "Context menu successfully removed!" -ForegroundColor Green
        
        # Refresh the shell icon cache (much gentler than restarting Explorer)
        Write-Host "Refreshing context menu cache..." -ForegroundColor Cyan
        & ie4uinit.exe -show | Out-Null
    } else {
        Write-Host "Context menu was not installed." -ForegroundColor Yellow
    }
}
catch {
    Write-Error "Failed to remove context menu: $_"
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
