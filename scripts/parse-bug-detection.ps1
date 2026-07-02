param(
    [string]$InputFile = 'bug-detection-output.txt',
    [string]$Output = 'artifacts/bug-detection.detailed.md'
)

$ErrorActionPreference = 'Stop'

if (-Not (Test-Path $InputFile)) { New-Item -Path $InputFile -ItemType File -Force | Out-Null }
$outputDir = Split-Path -Parent $Output
if ($outputDir -and -Not (Test-Path $outputDir)) { New-Item -ItemType Directory -Path $outputDir -Force | Out-Null }

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
    $lines += '- Detected NU1901 advisory (package advisory).'
} elseif ($content -match 'warning') {
    $lines += '- Build reported warnings; review analyzer diagnostics.'
} else {
    $lines += '- No analyzer advisories detected in build output.'
}
$lines += ''
$lines += '## Recommendations'
$lines += '- Update vulnerable package versions reported by NU advisories.'
$lines += '- Re-run analyzer-enabled build after applying fixes.'
$lines += ''
$lines | Out-File -FilePath $Output -Encoding UTF8
Write-Host "Wrote bug detection report: $Output"

