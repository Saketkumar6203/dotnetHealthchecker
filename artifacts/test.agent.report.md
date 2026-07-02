# Test Agent Report

Source file: `test.agent.md`
Pipeline job: `test`

## Role
- Execute unit tests for the .NET application.
- Verify that code changes do not break existing behavior.
- Support reproducible test workflows in CI.

## CI usage
- Job runs on `windows-latest`.
- Checks out the repository and sets up .NET 8.
- Restores dependencies.
- Executes:
  - `dotnet test --configuration Release --verbosity normal`

## Behavior
- Runs the full unit test suite.
- Validates code and tests together.
- Provides regression protection for the repo.

## Notes
- This job is the functional validation gate in CI.
- It ensures the repository stays test-safe before downstream publishing or deployment.
