param(
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

# Check if file exists
if (-not (Test-Path $FilePath)) {
    exit 1
}

# Calculate SHA256 hash and open VirusTotal
try {
    $hash = Get-FileHash -Path $FilePath -Algorithm SHA256
    $sha256 = $hash.Hash.ToLower()
    
    # Construct VirusTotal URL and open in browser
    $vtUrl = "https://www.virustotal.com/gui/file/$sha256"
    Start-Process $vtUrl
}
catch {
    exit 1
}
