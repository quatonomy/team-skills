---
name: qa-sign-off
description: "Use when explicitly requested to prepare and run local QA sign-off for a selected OpenSpec change, recording traceable test cases, results, and evidence."
argument-hint: "OpenSpec change name and approved local test environment"
disable-model-invocation: true
---

# Local QA sign-off

This opt-in workflow reads a selected OpenSpec change and records QA artifacts
inside that change. It is separate from the Developer agent's development
workflow: do not use it to bypass that agent's restriction on OpenSpec access.
Use an agent with permission to read the change, run the agreed checks, and
write the QA artifacts. An engineer remains responsible for sign-off.

## 1. Select the change and establish the scope

1. Ask for the exact active change name if it is not provided. Resolve it to an
   existing direct child of the repository's `openspec/changes/`, excluding
   `archive`. Do not create a change or guess between candidates. Confirm the
   selected name and path.
2. Read the selected change's available proposal, design, tasks, and delta
   specs, including relevant scenarios and constraints. Identify the affected
   codebases, user journeys, APIs, requirements, and acceptance criteria.
   Record source paths and requirement or scenario headings. If documents are
   missing, conflicting, or do not specify an expected outcome or measurable
   non-functional threshold, ask the engineer; record unresolved gaps and do
   not invent criteria or claim coverage.
3. Inspect the relevant implementation, existing test commands, Playwright
   configuration, Bruno collections, and environment setup where applicable.
   Identify which tests can actually be run locally and what needs services,
   test data, credentials, or manual participation. Do not assume a tool or
   service is installed, running, or configured.
4. Agree with the engineer on the test environment, intended scope, safe test
   data, potentially destructive or externally visible operations, and any
   manual checks. Do not target production, mutate shared data, install
   dependencies, or start infrastructure without explicit approval.

## 2. Create traceable test cases

Create a new run directory under the selected change:
`qa/runs/<UTC-timestamp>/`, using a unique timestamp such as
`20261124T170254Z`. If it already exists, choose another unique name; never
overwrite a prior run. Create `test-cases.md` there before executing checks.

Cover each applicable requirement and scenario, including success, failure,
boundary, and regression cases as appropriate. Consider non-functional areas
explicitly: security and privacy, accessibility, reliability and recovery,
concurrency and consistency, performance and scale, usability, and other
constraints stated in the change. Use proportionate tests; mark areas not
applicable with a reason rather than fabricating cases. For measurable criteria,
record the actual threshold, units, workload, and environment. If a criterion
is missing or cannot be measured, record the gap and a blocked case instead of
inventing a pass threshold.

For each case, record a stable ID, category, source document and heading,
requirement or risk, preconditions and test data, steps or exact command,
expected observable result, and planned evidence. Include a traceability
section mapping every requirement and scenario to case IDs or an explicit
uncovered reason, plus non-functional areas considered and any open questions.
Show the case list and gaps to the engineer before running it; resolve material
ambiguities and get approval for the scope and environment.

## 3. Execute and capture evidence

1. Execute approved cases locally using existing suitable tests and tools.
   Choose unit, feature, or integration checks according to the behaviour;
   use Playwright for suitable browser checks and Bruno for suitable API checks
   when available. Follow their existing project conventions. If no suitable
   check exists, describe the gap and ask before creating test code or changing
   project files. Small run-specific probes may be saved inside the run directory
   only when approved and safe. Do not change application code or OpenSpec
   planning artifacts as part of this workflow.
2. Capture actual evidence in the run's `evidence/` directory, associated with
   case IDs. For browser cases, capture real screenshots of relevant states when
   feasible, and retain relevant test output or traces when useful. For API and
   other automated checks, save actual command output, response or assertion
   results, and relevant logs or reports. Record command, exit status, target,
   and time. A screenshot is not an assertion and is not required for a
   non-visual case; select evidence suited to the check.
3. Use synthetic data and inspect evidence for secrets, tokens, personal data,
   and sensitive response content before retaining or displaying it. Do not
   store sensitive material in the repository. If safe evidence cannot be
   retained, mark the case blocked and explain; do not fabricate or substitute
   a narrative for evidence. Preserve meaningful failures and do not claim a
   screenshot, trace, or output exists unless the file was actually captured.
4. Classify each case as **PASS**, **FAIL**, **BLOCKED**, or **NOT RUN**.
   PASS requires observed expected behaviour and retained supporting evidence.
   FAIL means an observed outcome violates the expected result; distinguish
   setup or environment blockers from product failures. Record actual results,
   relative evidence links, and failure or blocker details. Manual checks require
   the engineer's observed outcome and safe evidence; an instruction to perform
   a check is not a result.
5. Continue independent safe checks after a failure, and report any checks
   that could not be completed. Do not silently skip cases or convert missing
   tools, thresholds, or evidence into passes. Verify each linked evidence
   file exists and can be accessed before reporting.

## 4. Record and display results

Write `results.md` in the same run directory with:

- Change name, run ID and time, environment, code revision and working-tree
  state, test scope, and any relevant configuration or tool versions. If the
  code changes during the run, identify affected results as stale and rerun
  them or mark them not verified.
- A table with every case ID, status, actual result, relative evidence links,
  and issue or blocker. Include counts by status, uncovered requirements,
  missing evidence, non-functional coverage gaps, and approved exceptions.
- An overall recommendation: **READY FOR HUMAN REVIEW** only if all applicable
  cases pass, requirements are covered, evidence is retained, and no unresolved
  gaps remain; otherwise **NOT READY**, with reasons. This is not approval.
- A human sign-off section initially marked **PENDING**, with the intended
  approver, decision, time, and comments left for the authorised person. Only
  record a decision when that person explicitly provides it; attribute it and
  do not infer approval from a passing run.

Display the case and result summary, counts, recommendation, unresolved gaps,
and paths to `test-cases.md`, `results.md`, and evidence to the engineer.
Do not archive the change, update task checkboxes, or edit the proposal, design,
or specs. If any artifact cannot be saved or is ignored by version control,
report it and agree how it will be retained. Do not commit evidence without
the engineer's instruction.

This is a local, agent-guided process, not a configured pipeline gate. Future CI
integration must provide its own non-interactive inputs, artifact retention,
access controls, and approval mechanism.
