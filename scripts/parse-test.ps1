$ErrorActionPreference = 'Stop'
param(
    [string]$InputFile = 'test-output.txt',
    [string]$Output = 'artifacts/test.detailed.md'
)

if (-Not (Test-Path $InputFile)) { New-Item -Path $InputFile -ItemType File -Force | Out-Null }

$content = Get-Content -Path $InputFile -Raw

$lines = @()
$lines += '# Test Job Detailed Report'
$lines += ''
$lines += "Generated: $(Get-Date -Format u)"
$lines += ''
$lines += '## Command output'
$lines += '```'
$lines += $content
$lines += '```'
$lines += ''

$lines += '## Findings'
if ($content -match 'Total tests:') {
    if ($content -match 'Failed: (\d+)') {
        $failed = [int]($matches[1])
        if ($failed -gt 0) { $lines += "- $failed test(s) failed. See output above." } else { $lines += '- All tests passed.' }
    } else {
        $lines += '- Test summary not detected; inspect output.'
    }
} elseif ($content -match 'Failed!') {
    $lines += '- Tests reported failures.'
} else {
    $lines += '- No test summary detected; inspect output for details.'
}
$lines += ''
$lines += '## Recommendations'
$lines += '- Fix failing tests and re-run the job.'
$lines += '- If failures are flaky, add retry or investigate root cause.'
$lines += ''
$lines | Out-File -FilePath $Output -Encoding UTF8
Write-Host "Wrote test report: $Output"
