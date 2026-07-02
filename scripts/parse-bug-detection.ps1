$ErrorActionPreference = 'Stop'
param(
    [string]$InputFile = 'bug-detection-output.txt',
    [string]$Output = 'artifacts/bug-detection.detailed.md'
)

if (-Not (Test-Path $InputFile)) { New-Item -Path $InputFile -ItemType File -Force | Out-Null }

$content = Get-Content -Path $InputFile -Raw

$lines = @()
$lines += '# Bug Detection Detailed Report'
$lines += ''
$lines += "Generated: $(Get-Date -Format u)"
$lines += ''
$lines += '## Command output'
$lines += '```'
$lines += $content
$lines += '```'
$lines += ''

$lines += '## Findings'
if ($content -match 'NU1901') {
    $matches = ([regex] 'NU1901[:\s-]*([^\n]+)')
    $lines += '- Detected NU1901 advisory (package advisory).'
} elseif ($content -match 'warning') {
    $lines += '- Build reported warnings; review analyzer diagnostics.'
} else {
    $lines += '- No analyzer advisories detected in build output.'
}
$lines += ''
$lines += '## Recommendations'
$lines += '- Update vulnerable package versions reported by NU advisories.'n
$lines += '- Re-run analyzer-enabled build after applying fixes.'
$lines += ''
$lines | Out-File -FilePath $Output -Encoding UTF8
Write-Host "Wrote bug detection report: $Output"
