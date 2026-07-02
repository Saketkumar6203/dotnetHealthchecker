# dotnet Agent Report

Source file: `dotnet Agent.agent.md`
Pipeline role: workspace development assistant only

## Role
- General .NET development support in VS Code.
- Assist with project setup, debugging, ASP.NET Core, Entity Framework, and CLI workflows.
- Provide guidance for .NET development tasks, not a pipeline-run agent.

## CI usage
- Not directly executed as a GitHub Actions job.
- This file is a workspace-specific agent definition used for developer assistance.

## Behavior
- Helps developers with .NET project questions, debugging, and build guidance.
- Supports local development rather than CI automation.

## Notes
- This agent file is included in the repo for workspace assistance.
- It does not correspond to a pipeline artifact job like the other agents.
