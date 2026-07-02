# Security Scan Agent Report

Source file: `security-scan.agent.md`
Pipeline job: `security-scan`

## Role
- Scan C# source code for security issues.
- Analyze dependencies for known vulnerabilities.
- Help harden the repository against security risks.

## CI usage
- Job runs on `ubuntu-latest`.
- Checks out the repository and sets up .NET 8.
- Performs CodeQL initialization and analysis.
- Restores dependencies.
- Executes dependency vulnerability scanning:
  - `dotnet list package --vulnerable`

## Behavior
- Uses `github/codeql-action/init@v3` to configure language analysis.
- Uses `github/codeql-action/autobuild@v3` for building the codebase.
- Uses `github/codeql-action/analyze@v3` with `category: "security"`.
- Fails the job if any high or critical vulnerabilities are detected.

## Notes
- This job combines static security analysis with dependency vulnerability checks.
- It is intended to prevent security regressions in CI.
