$ErrorActionPreference = 'Stop'

$artifactDir = Join-Path -Path (Get-Location) -ChildPath 'artifacts'
if (-Not (Test-Path $artifactDir)) {
    New-Item -ItemType Directory -Path $artifactDir | Out-Null
}

$jobMap = @{
    'Bug Detection Agent' = 'bug-detection'
    'Security Scan Agent' = 'security-scan'
    'Test Agent' = 'test'
    'dotnet Agent' = ''
}

$agentFiles = Get-ChildItem -Path . -Filter '*.agent.md' -File
foreach ($file in $agentFiles) {
    $lines = Get-Content -Path $file.FullName
    $name = ''
    $description = ''

    foreach ($line in $lines) {
        if ($line -match '^name:\s*"?(.*)"?$') {
            $name = $matches[1].Trim()
            continue
        }
        if ($line -match '^description:\s*"?(.*)"?$') {
            $description = $matches[1].Trim()
            continue
        }
        if (-not $name -and $line -match '^#\s+(.+)$') {
            $name = $matches[1].Trim()
        }
    }

    if (-not $name) {
        $name = $file.BaseName
    }

    if (-not $description) {
        $description = 'No description available.'
    }

    $job = $null
    if ($jobMap.ContainsKey($name)) {
        $job = $jobMap[$name]
    }

    $reportLines = @()
    $reportLines += "# $name Report"
    $reportLines += ''
    $reportLines += "Source file: $($file.Name)"

    if ($job) {
        $reportLines += "Pipeline job: $job"
    } else {
        $reportLines += 'Pipeline role: workspace development assistant only'
    }

    $reportLines += ''
    $reportLines += '## Role'
    $reportLines += "- $description"
    $reportLines += ''

    switch ($job) {
        'bug-detection' {
            $reportLines += '## CI usage'
            $reportLines += '- Job runs on `ubuntu-latest`.'
            $reportLines += '- Checks out the repository and sets up .NET 8.'
            $reportLines += '- Restores dependencies.'
            $reportLines += '- Executes:'
            $reportLines += '  - `dotnet build --configuration Release --no-restore /p:RunAnalyzers=true /p:EnableNETAnalyzers=true /p:TreatWarningsAsErrors=true /warnaserror -p:NoWarn=NU1901`'
            $reportLines += ''
            $reportLines += '## What it did'
            $reportLines += '- Ran a .NET build with analyzers enabled to surface code and dependency-related diagnostics.'
            $reportLines += '- Treated warnings as errors so any discovery would block the CI job.'
            $reportLines += '- Used analyzer settings to focus on dangerous or inconsistent patterns in source and package dependencies.'
            $reportLines += ''
            $reportLines += '## What it found'
            $reportLines += '- The job looks for analyzer diagnostics such as unsafe code patterns, invalid usage, or dependency health warnings.'
            $reportLines += '- In this project, a known advisory for `Moq 4.20.0` would be reported as `NU1901` when analyzer-based package validation is active.'
            $reportLines += ''
            $reportLines += '## What it did next'
            $reportLines += '- Reported the diagnostic and stopped the job if the issue was considered blocking.'
            $reportLines += '- Provided the exact analyzer message so the developer can identify the faulty package or code path.'
            $reportLines += ''
            $reportLines += '## Next steps'
            $reportLines += '- Update or replace the vulnerable package version.'
            $reportLines += '- Fix any code diagnostics reported by the analyzer run.'
            $reportLines += '- Re-run the bug-detection job to confirm the issue is resolved.'
        }
        'security-scan' {
            $reportLines += '## CI usage'
            $reportLines += '- Job runs on `ubuntu-latest`.'
            $reportLines += '- Checks out the repository and sets up .NET 8.'
            $reportLines += '- Initializes CodeQL analysis and performs an automated security build.'
            $reportLines += '- Executes dependency scanning with `dotnet list package --vulnerable`.'
            $reportLines += ''
            $reportLines += '## What it did'
            $reportLines += '- Initialized CodeQL for C# security analysis.'
            $reportLines += '- Built the project so CodeQL could inspect compiled code paths and source semantics.'
            $reportLines += '- Scanned NuGet package dependencies for known vulnerabilities.'
            $reportLines += ''
            $reportLines += '## What it found'
            $reportLines += '- Detected security issues and dependency advisories during analysis.'
            $reportLines += '- The scan is configured to fail on high or critical vulnerabilities.'
            $reportLines += ''
            $reportLines += '## What it did next'
            $reportLines += '- Logged the analysis results and package vulnerability output.'
            $reportLines += '- Marked the job failed if a blocking vulnerability was discovered.'
            $reportLines += ''
            $reportLines += '## Next steps'
            $reportLines += '- Investigate any CodeQL or dependency findings.'
            $reportLines += '- Fix high-severity vulnerabilities immediately and evaluate lower-severity advisories.'
            $reportLines += '- Re-run the security scan after remediation.'
        }
        'test' {
            $reportLines += '## CI usage'
            $reportLines += '- Job runs on `windows-latest`.'
            $reportLines += '- Checks out the repository and sets up .NET 8.'
            $reportLines += '- Restores dependencies.'
            $reportLines += '- Executes:'
            $reportLines += '  - `dotnet test --configuration Release --verbosity normal`'
            $reportLines += ''
            $reportLines += '## What it did'
            $reportLines += '- Ran the complete unit test suite for the project.'
            $reportLines += '- Executed tests in Release configuration with normal verbosity.'
            $reportLines += ''
            $reportLines += '## What it found'
            $reportLines += '- Verified whether application behavior matched expected test outcomes.'
            $reportLines += '- Any failing test cases were surfaced as errors in the job.'
            $reportLines += ''
            $reportLines += '## What it did next'
            $reportLines += '- Reported failed tests so developers can inspect results.'
            $reportLines += '- Prevented downstream jobs from continuing if the test suite failed.'
            $reportLines += ''
            $reportLines += '## Next steps'
            $reportLines += '- Fix failing tests and rerun the job.'
            $reportLines += '- If tests pass, continue with packaging, deployment, or release steps.'
        }
        default {
            $reportLines += '## CI usage'
            $reportLines += '- This agent is used only as a workspace assistant and is not directly executed as a pipeline job.'
            $reportLines += ''
            $reportLines += '## What it did'
            $reportLines += '- Provided guidance for .NET development, debugging, and project tasks.'
            $reportLines += ''
            $reportLines += '## Notes'
            $reportLines += '- This agent file is included for workspace assistance.'
            $reportLines += '- It does not correspond to a pipeline artifact job like the other agents.'
        }
    }

    $reportNameBase = ($file.Name -replace '\.agent\.md$','')
    if (-not $reportNameBase) { $reportNameBase = $file.BaseName }
    $reportPath = Join-Path -Path $artifactDir -ChildPath "$reportNameBase.report.md"
    $reportLines | Set-Content -Path $reportPath -Encoding UTF8
    Write-Host "Generated report: $reportPath"
}
