# Code Review Output

Lead with findings. Keep summaries secondary.

## Finding Format

Use this structure for every reportable finding:

```text
[Severity] Short actionable title

Location: file and relevant symbol or lines
Scenario: The reachable conditions that trigger the issue
Impact: What breaks, leaks, duplicates, or becomes incompatible
Evidence: Why the current code produces the impact
Recommendation: The smallest practical remediation direction
Validation: Test or check that proves the fix
```

Use precise language. Do not claim certainty beyond available evidence.

## Severity

- `CRITICAL`: Directly exploitable security issue, irreversible widespread data loss, or immediate
  catastrophic production impact.
- `HIGH`: Likely correctness, security, data-integrity, availability, or backward-compatibility
  failure with substantial impact.
- `MEDIUM`: Reachable defect with contained impact, unsafe edge case, or meaningful operational and
  cross-team risk.
- `LOW`: Minor but concrete maintainability, consistency, or defensive-coding issue.

Do not inflate severity because a topic sounds important. Base it on reachability, likelihood,
impact, and existing controls.

## Required Report Order

1. Findings ordered by severity
2. Open questions and assumptions that affect approval
3. Missing tests or verification gaps
4. Brief change summary

If no reportable findings exist, say so clearly and state remaining test or integration risks.

## Approval Signals

End the review with one of:

- `Ready`: No reportable issue remains.
- `Ready with follow-up`: Only non-blocking work remains, with explicit owners or scope.
- `Changes required`: At least one blocking correctness, security, compatibility, or operational
  issue remains.

Do not block approval solely for optional design preferences.

For an HTTP contract change, stale or missing required Swagger/OpenAPI is blocking when it can
mislead consumers, generated clients, QA, or another team.
