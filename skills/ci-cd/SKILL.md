---
name: ci-cd
description: "Use when designing, implementing, reviewing, or troubleshooting CI/CD, build pipelines, GitHub Actions, deployment workflows, release automation, or pipeline failures."
---

# CI/CD

Work from the engineer's intent and the existing pipeline and deployment
conventions. Do not assume a CI provider, runner, release process, or target
environment.

1. Clarify the intended triggers, build and test outputs, deployment targets,
   approval gates, and success criteria. Inspect existing workflows, scripts,
   dependencies, permissions, environment configuration, and documentation.
   Ask about material unknowns before choosing a pipeline design.
2. Trace the path from source to build, test, artifact, release, and deployment.
   Consider reproducibility, caching, artifact provenance, failure reporting,
   concurrency, rollback, and operational ownership. Examine trust boundaries,
   untrusted pull requests, least-privilege tokens, secret handling, third-party
   actions and dependencies, and protected environments as applicable.
3. Present options and trade-offs for consequential pipeline or deployment
   changes and obtain the engineer's decision. Prefer existing project tools and
   conventions; avoid adding stages, services, or abstractions without a need.
4. Make changes only within the requested scope. Follow the
   [TDD skill](../test-driven-development/SKILL.md) for behaviour changes,
   including its process for exceptions. Run the smallest relevant existing
   workflow checks, linters, or safe local equivalents; distinguish local
   validation from an actual hosted pipeline or deployment.
5. Obtain explicit approval before triggering workflows with external or
   deployment effects, publishing artifacts, modifying remote settings or
   secrets, or accessing shared or production environments. Agree on the target
   and side effects first. Do not expose credentials or sensitive logs.
6. Report changes, commands and observed results, which pipeline stages and
   environments were actually exercised, and remaining gaps or risks. Never
   claim a release or deployment succeeded without evidence.
