#Requires -Version 7.0
param(
    [Parameter(Mandatory = $true)]
    [string]$TemplatePath,

    [Parameter(Mandatory = $true)]
    [string]$ManifestPath
)

$ErrorActionPreference = "Stop"
$failures = @()

if (-not (Test-Path $TemplatePath)) {
    $failures += "Template path not found: $TemplatePath"
}

if (-not (Test-Path $ManifestPath)) {
    $failures += "Manifest path not found: $ManifestPath"
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output "FAIL: $_" }
    exit 1
}

$content = Get-Content -Path $ManifestPath -Raw
$requiredKeys = @("id:", "version:", "status:", "owners:", "artifacts:", "inputs:", "validation:", "governance:")
foreach ($key in $requiredKeys) {
    if (-not $content.Contains($key)) {
        $failures += "Manifest missing required key: $key"
    }
}

if ($TemplatePath.EndsWith(".bicep")) {
    $azAvailable = Get-Command az -ErrorAction SilentlyContinue
    if ($azAvailable) {
        az bicep build --file $TemplatePath --stdout | Out-Null
        if ($LASTEXITCODE -ne 0) {
            $failures += "Bicep build failed"
        }
    } else {
        Write-Output "WARN: az CLI not available, skipped bicep build"
    }
}

if ($TemplatePath.EndsWith(".tf")) {
    $tfAvailable = Get-Command terraform -ErrorAction SilentlyContinue
    if ($tfAvailable) {
        $dir = Split-Path -Parent $TemplatePath
        terraform "-chdir=$dir" init -backend=false | Out-Null
        terraform "-chdir=$dir" validate | Out-Null
        if ($LASTEXITCODE -ne 0) {
            $failures += "Terraform validate failed"
        }
    } else {
        Write-Output "WARN: terraform not available, skipped terraform validate"
    }
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Output "FAIL: $_" }
    exit 1
}

Write-Output "PASS: Template and manifest validation completed"
