---
name: bruno-api-testing
description: "Use when designing, writing, running, or diagnosing Bruno API requests, collections, and automated assertions."
---

# Bruno API testing

Work from the engineer's stated intent and the relevant codebase, not OpenSpec
artifacts. Follow the [TDD skill](../test-driven-development/SKILL.md) for
behaviour changes, including observing the intended failure before implementing.

1. Identify the API behaviour and choose valuable success, validation,
   authorisation, and error scenarios for the relevant risk. Discuss when a
   smaller unit or integration test would be more appropriate.
2. Inspect existing Bruno collections, environments, scripts, authentication
   conventions, and documented run commands. Do not assume Bruno or an API
   service is installed or running; ask before installing dependencies or
   changing infrastructure.
3. Use the existing collection format and conventions. Assert meaningful status,
   response body and headers as appropriate, including relevant error
   behaviour. Keep requests independent where practical and make test data
   setup and cleanup explicit.
4. Use an approved non-production target and non-sensitive test data. Never
   commit credentials, tokens, or real personal data; use the project's
   approved secret and environment handling. Ask before running requests that
   mutate shared data or have external side effects.
5. Run the focused collection or request using the project's supported command.
   Distinguish expected behaviour failures from authentication, connectivity,
   or setup failures. Report the command, target environment, actual outcomes,
   and anything not verified without exposing secrets.

Discuss consequential choices with the engineer. Do not change code, tests, or
collections unless requested.
