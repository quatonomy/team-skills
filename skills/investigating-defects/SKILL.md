---
name: investigating-defects
description: "Use when investigating a bug, unexpected behaviour, regression, error, or failing test and guiding a root-cause fix."
---

# Investigating defects

Work from the engineer's description and relevant codebase, not OpenSpec
artifacts. Do not change code or tests unless the engineer requests it.

1. Clarify expected and observed behaviour, scope, reproduction steps,
   environment, and impact. Inspect relevant code, tests, and available
   evidence; do not assume the first symptom is the root cause.
2. Reproduce safely using an appropriate test environment. Establish whether
   the failure is in the application, test, configuration, or dependency.
   Avoid exposing sensitive data or mutating shared systems without approval.
3. Form specific hypotheses and investigate with focused, minimally invasive
   checks. Distinguish facts from assumptions and update the engineer when
   material uncertainty or a consequential choice arises.
4. Once the intended behaviour and likely cause are understood, propose a
   focused regression test and a root-cause fix. Follow the
   [TDD skill](../test-driven-development/SKILL.md): observe the test fail
   for the defect before implementing the fix, then confirm it passes.
   If reproduction or the red step is blocked, stop and follow its exception
   process rather than silently proceeding.
5. Report the evidence, root cause or remaining uncertainty, checks and actual
   results, and any unverified impact. Avoid unrelated changes.
