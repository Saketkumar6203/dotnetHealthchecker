$ErrorActionPreference = 'Stop'

$artifactDir = Join-Path -Path (Get-Location) -ChildPath 'artifacts'
if (-Not (Test-Path $artifactDir)) { New-Item -ItemType Directory -Path $artifactDir | Out-Null }

$reportPath = Join-Path -Path $artifactDir -ChildPath 'dotnet-agent.execution.md'

$lines = @()
$lines += '# dotnet Agent Execution Report'
$lines += ''
$lines += 'Generated on: ' + (Get-Date).ToString('u')
$lines += ''
$lines += '## What this agent runs'
$lines += '- Restore project dependencies'
$lines += '- Build the solution in Release configuration'
$lines += '- (Optional) Run unit tests'
$lines += ''
$commands = @(
    @{name='dotnet --info'; cmd='dotnet --info'},
    @{name='dotnet restore'; cmd='dotnet restore'},
    @{name='dotnet build'; cmd='dotnet build --configuration Release --no-restore'},
    @{name='dotnet test (short)'; cmd='dotnet test --configuration Release --no-build --no-restore --verbosity minimal'}
)

foreach ($c in $commands) {
    $lines += "## $($c.name)"
    $lines += ''
    try {
        $output = & $c.cmd 2>&1 | Out-String
        $lines += '```'
        $lines += $output.Trim()
        $lines += '```'
    } catch {
        $lines += "Command failed: $($_.Exception.Message)"
    }
    $lines += ''
}

$lines += '## Summary and next steps'
$lines += '- Inspect the command outputs above for failures or warnings.'
$lines += '- If dependency or analyzer warnings are reported, update package versions or fix code issues.'
$lines += '- Re-run CI after addressing findings.'

$lines | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "Wrote report: $reportPath"
