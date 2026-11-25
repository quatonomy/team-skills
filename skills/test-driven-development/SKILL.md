---
name: test-driven-development
description: "Use when implementing or guiding behaviour changes with test-driven development, including choosing and running unit, feature, or integration tests."
---

# Test-driven development

Use the engineer's stated intent and the relevant codebase as context. Do not
read or modify OpenSpec artifacts to determine requirements.

## Red, green, refactor

For each behaviour change:

1. Agree on a small observable behaviour and choose a valuable test level.
   Identify the existing test runner and how to run the focused test.
2. Before changing production code for that behaviour, write a focused automated
   test. Run it and confirm it fails for the intended missing or incorrect
   behaviour, not because of a setup, compilation, or unrelated error.
3. Only after observing that failure, make the smallest production change to
   satisfy the test. Run the test again and confirm it passes.
4. Refactor as needed without changing behaviour, rerunning relevant tests to
   confirm they remain green. Repeat the cycle for the next behaviour.

If the engineer is writing the code, guide them through these steps and ask for
the results if you cannot observe them. Do not imply that a step was completed
without evidence.

## Blockers and exceptions

If a suitable test cannot be written or run, or the failure cannot be verified,
stop before implementing the affected behaviour. Explain the blocker and ask
the engineer how to proceed. Do not install dependencies or alter infrastructure
without their approval.

Only depart from test-first if the engineer explicitly approves an exception
after hearing the reason and risks. State that TDD was not followed, what
verification was performed, and what remains unverified. Do not silently
substitute a passing test, a test written after implementation, or an unrun test
for an observed red step.

For behaviour-preserving refactoring, establish a passing relevant test baseline
first; if no adequate baseline exists, discuss adding coverage before changing
the code. Documentation-only changes do not require a red-green cycle.

## Test choices and evidence

- Choose unit, feature, and integration tests based on behaviour and risk;
  not every change needs all three. Test observable outcomes rather than
  incidental implementation details.
- Follow the codebase's existing tools and test conventions.
  Use Playwright for browser tests and Bruno for API tests when appropriate
  and available; do not assume they or a test service are configured.
- Run the smallest relevant checks during the cycle, then other checks
  appropriate to the change. Report commands and actual outcomes, including
  the observed red and green results, any exception, and remaining gaps.
