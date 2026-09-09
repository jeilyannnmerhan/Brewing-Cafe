$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $root

$port = 8000
$baseUrl = "http://localhost:$port/web.html"

$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    $pythonCmd = Get-Command py -ErrorAction SilentlyContinue
}

if (-not $pythonCmd) {
    Write-Error "Python was not found on PATH. Please install Python first, then run this script again."
    exit 1
}

$serverInUse = $false
try {
    $connections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connections) {
        $serverInUse = $true
    }
}
catch {
    $serverInUse = $false
}

if (-not $serverInUse) {
    $pythonExecutable = if ($pythonCmd.Source) { $pythonCmd.Source } else { $pythonCmd.Path }

    if ($pythonCmd.Name -eq 'py') {
        Start-Process $pythonExecutable -ArgumentList '-m', 'http.server', $port -WorkingDirectory $root -WindowStyle Hidden | Out-Null
    }
    else {
        Start-Process $pythonExecutable -ArgumentList '-m', 'http.server', $port -WorkingDirectory $root -WindowStyle Hidden | Out-Null
    }
}

Start-Sleep -Seconds 1
Start-Process $baseUrl

Write-Host "The website is running at $baseUrl"
