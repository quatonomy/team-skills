---
description: "Use when writing, reviewing, or modifying TypeScript and TSX code."
applyTo: "**/*.ts, **/*.tsx, **/*.mts, **/*.cts"
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.mts"
  - "**/*.cts"
---

# TypeScript coding standards

- Follow the project's TypeScript configuration, formatting, lint rules, and
  established conventions. Use the existing package manager and tooling.
- Prefer clear, small functions and descriptive names. Reuse existing code and
  types before introducing new abstractions or dependencies.
- Preserve type safety. Prefer inference where clear, explicit types at public
  boundaries, and `unknown` with narrowing for untrusted values. Avoid `any`,
  unchecked assertions, and non-null assertions unless justified.
- Validate external data at runtime using the project's existing validation
  approach. Type declarations alone do not validate inputs.
- Handle nullability, asynchronous failures, and error cases explicitly. Do not
  silently swallow errors or expose sensitive information.
- Prefer immutable values where practical and avoid hidden mutation. Use
  discriminated unions and exhaustive handling for finite variants.
- Add or update tests for changed behaviour and run the relevant tests,
  type-checker, and linter using existing project commands when available.
