---
title: Restart Failure
labels: bug
---

Workflow with Issue: {{ workflow }}
Job Failed: {{ env.GITHUB_JOB }}
Last Commit: {{ env.LAST_COMMIT }}
Number of times run: {{ env.GITHUB_ATTEMPTS }}
Last run by: {{ env.LAST_RUN_BY }}
Github Action Run: https://github.com/{{ env.REPO }}/actions/runs/{{ env.RUN_ID }}
