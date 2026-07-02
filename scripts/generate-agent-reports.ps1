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
    $reportLines += "Source file: `$($file.Name)`"

    if ($job) {
        $reportLines += "Pipeline job: `$job`"
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
            $reportLines += '  - `dotnet build --configuration Release --no-restore /p:RunAnalyzers=true /p:EnableNETAnalyzers=true /p:TreatWarningsAsErrors=true /warnaserror`'
            $reportLines += ''
            $reportLines += '## Behavior'
            $reportLines += '- Enables .NET analyzers during build.'
            $reportLines += '- Treats warnings as errors.'
            $reportLines += '- Fails the job if analyzer diagnostics are reported.'
            $reportLines += ''
            $reportLines += '## Notes'
            $reportLines += '- This job serves as a static bug detection gate in CI.'
            $reportLines += '- It is designed to catch build-time quality issues before deployment.'
        }
        'security-scan' {
            $reportLines += '## CI usage'
            $reportLines += '- Job runs on `ubuntu-latest`.'
            $reportLines += '- Checks out the repository and sets up .NET 8.'
            $reportLines += '- Initializes CodeQL and performs a security build.'
            $reportLines += '- Executes dependency vulnerability scanning with `dotnet list package --vulnerable`.'
            $reportLines += ''
            $reportLines += '## Behavior'
            $reportLines += '- Uses `github/codeql-action/init@v3` to configure security analysis.'
            $reportLines += '- Uses `github/codeql-action/autobuild@v3` to build the codebase for analysis.'
            $reportLines += '- Uses `github/codeql-action/analyze@v3` with `category: "security"`.'
            $reportLines += '- Fails the job if any high or critical vulnerabilities are detected.'
            $reportLines += ''
            $reportLines += '## Notes'
            $reportLines += '- This job combines static security analysis with dependency vulnerability checks.'
            $reportLines += '- It is intended to prevent security regressions in CI.'
        }
        'test' {
            $reportLines += '## CI usage'
            $reportLines += '- Job runs on `windows-latest`.'
            $reportLines += '- Checks out the repository and sets up .NET 8.'
            $reportLines += '- Restores dependencies.'
            $reportLines += '- Executes:'
            $reportLines += '  - `dotnet test --configuration Release --verbosity normal`'
            $reportLines += ''
            $reportLines += '## Behavior'
            $reportLines += '- Runs the full unit test suite.'
            $reportLines += '- Validates code and tests together.'
            $reportLines += '- Provides regression protection for the repo.'
            $reportLines += ''
            $reportLines += '## Notes'
            $reportLines += '- This job is the functional validation gate in CI.'
            $reportLines += '- It ensures the repository stays test-safe before downstream publishing or deployment.'
        }
        default {
            $reportLines += '## CI usage'
            $reportLines += '- This agent is used only as a workspace assistant and is not directly executed as a pipeline job.'
            $reportLines += ''
            $reportLines += '## Behavior'
            $reportLines += '- Helps developers with .NET project questions, debugging, and build guidance.'
            $reportLines += '- Supports local development rather than CI automation.'
            $reportLines += ''
            $reportLines += '## Notes'
            $reportLines += '- This agent file is included for workspace assistance.'
            $reportLines += '- It does not correspond to a pipeline artifact job like the other agents.'
        }
    }

    $reportPath = Join-Path -Path $artifactDir -ChildPath "${($file.BaseName)}.report.md"
    $reportLines | Set-Content -Path $reportPath -Encoding UTF8
    Write-Host "Generated report: $reportPath"
}
