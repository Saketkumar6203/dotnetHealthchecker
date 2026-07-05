# Sonar Output Summary

This repository workflow now generates the Sonar output log summary in the Actions artifact `sonar-logs/one.md`.

During the `sonar` job, the workflow concatenates:
- `sonar-logs/begin.log`
- `sonar-logs/build.log`
- `sonar-logs/end.log`
- `sonar-logs/report-task.txt`

If you want the actual Sonar output, run the workflow and download the `sonar-logs` artifact from the Actions run.
