$ErrorActionPreference = 'Stop'
param(
    [string]$InputFile = 'security-scan-output.txt',
    [string]$Output = 'artifacts/security-scan.detailed.md'
)

if (-Not (Test-Path $InputFile)) { New-Item -Path $InputFile -ItemType File -Force | Out-Null }

$content = Get-Content -Path $InputFile -Raw

$lines = @()
$lines += '# Security Scan Detailed Report'
$lines += ''
$lines += "Generated: $(Get-Date -Format u)"
$lines += ''
$lines += '## Command output'
$lines += '```'
$lines += $content
$lines += '```'
$lines += ''

$lines += '## Findings'
if ($content -match 'Severity: (High|Critical)') {
    $lines += '- One or more high/critical vulnerabilities detected. See output above.'
} elseif ($content -match 'NU[0-9]{4}') {
    $lines += '- Package advisories detected (NU* entries). Review package versions.'
} else {
    $lines += '- No high or critical vulnerabilities found by `dotnet list package --vulnerable`.'
}
$lines += ''
$lines += '## Recommendations'
$lines += '- Prioritize fixing high/critical CVEs immediately.'
$lines += '- For package advisories, update to patched versions or apply mitigations.'
$lines += ''
$lines | Out-File -FilePath $Output -Encoding UTF8
Write-Host "Wrote security scan report: $Output"
