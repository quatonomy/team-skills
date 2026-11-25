---
name: playwright-testing
description: "Use when designing, writing, running, or diagnosing Playwright browser and user-facing feature tests."
---

# Playwright testing

Work from the engineer's stated intent and the relevant codebase, not OpenSpec
artifacts. Follow the [TDD skill](../test-driven-development/SKILL.md) for
behaviour changes; writing a browser test does not exempt a change from red,
green, and refactor.

1. Identify the user-visible behaviour, risk, and whether a browser test adds
   confidence beyond a smaller test. Agree on meaningful scenarios, including
   relevant failure and accessibility behaviour.
2. Inspect the project's existing Playwright configuration, scripts, fixtures,
   browser targets, and test environment. Ask before adding dependencies,
   browsers, or infrastructure. If the setup is missing or cannot be run,
   report the blocker rather than assuming a test passed.
3. Use isolated, deterministic test data and the project's fixtures. Prefer
   user-facing role, label, and text locators; use test IDs when appropriate.
   Assert observable outcomes and avoid brittle selectors, arbitrary sleeps,
   and unnecessary reliance on network or shared state.
4. Run the smallest relevant test with the project's configured command. For
   TDD, confirm the expected behavioural failure before implementation, then
   confirm success; diagnose setup and timing failures separately. Expand
   coverage as appropriate and inspect failure output or traces if available.
5. Report commands, actual results, browsers or environments covered, and
   remaining gaps. Never expose credentials or sensitive data in logs,
   screenshots, or traces; use approved non-production test environments.

Discuss important test design and environment decisions with the engineer.
Do not change code or tests unless requested.
