# Bug Detection Agent Report

Source file: `bug-detection.agent.md`
Pipeline job: `bug-detection`

## Role
- Identify likely code defects, unsafe patterns, and risky logic in .NET applications.
- Focus on analyzer-based build checks and compile-time quality issues.

## CI usage
- Job runs on `ubuntu-latest`.
- Checks out the repository and sets up .NET 8.
- Restores dependencies.
- Executes:
  - `dotnet build --configuration Release --no-restore /p:RunAnalyzers=true /p:EnableNETAnalyzers=true /p:TreatWarningsAsErrors=true /warnaserror`

## Behavior
- Enables .NET analyzers during build.
- Treats warnings as errors.
- Fails the job if analyzer diagnostics are reported.

## Notes
- This job serves as a static bug detection gate in CI.
- It is designed to catch build-time quality issues before deployment.
