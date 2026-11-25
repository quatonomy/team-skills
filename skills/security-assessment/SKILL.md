---
name: security-assessment
description: "Use when assessing security risks in a design, implementation, API, authentication, data handling, or code change."
---

# Security assessment

Work from the engineer's stated intent and the relevant codebase, not OpenSpec
artifacts. Keep the assessment within the authorised scope and discuss risks
and decisions with the engineer.

1. Identify the assets, sensitive data, entry points, actors, privileges, and
   trust boundaries affected by the requested change. Ask about material unknowns
   instead of inventing requirements.
2. Examine relevant risks, such as authentication and authorisation, input
   validation and injection, secrets, data exposure, dependency risks, logging,
   error handling, and abuse or resource exhaustion. Consider only applicable
   risks and trace claims to evidence in the code or configuration.
3. Explain plausible impact, conditions, and uncertainty. Distinguish observed
   vulnerabilities from hypotheses and missing evidence. Propose proportionate
   mitigations and security tests, with trade-offs and residual risks.
4. Agree on next steps with the engineer. Do not make edits unless requested.
   For behaviour changes, follow the [TDD skill](../test-driven-development/SKILL.md).
   Do not run intrusive tests, use real credentials, or target external
   systems without explicit authorisation and an agreed safe scope.
5. Report what was examined and verified, any blockers, and what remains
   unverified. Do not claim that a system is secure based on a partial review.
