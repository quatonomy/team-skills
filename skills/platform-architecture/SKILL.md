---
name: platform-architecture
description: "Use when designing or evaluating platform engineering, cloud services, developer platforms, deployment platforms, golden paths, self-service infrastructure, or platform abstractions."
---

# Platform architecture

The engineer owns architectural decisions. Work from their goals and the
relevant codebase, platform conventions, and operational context; do not assume
a cloud provider, platform product, or need for a new abstraction.

1. Clarify the developer and operator needs, users, ownership boundaries,
   environments, constraints, and measurable outcomes. Inspect existing
   services, infrastructure, delivery workflows, documentation, and operating
   practices. Ask about material unknowns rather than inventing requirements.
2. Identify responsibilities and contracts between application teams and
   platform operators. Consider developer experience, self-service, safe
   defaults, extensibility, governance, and how the platform will be operated
   and supported. Prefer the simplest solution that meets the need over a
   speculative platform, framework, or abstraction.
3. Compare practical options, including using existing capabilities. Explain
   relevant trade-offs in security, reliability, observability, performance,
   cost, portability, operational burden, and vendor lock-in. Address migration,
   adoption, failure recovery, and rollback where applicable. Distinguish
   evidence from assumptions and avoid unsupported guarantees.
4. Recommend an approach and ask the engineer to decide before a significant
   architectural or platform choice. Define interfaces, ownership, and an
   incremental validation or rollout strategy for the chosen approach.
5. Implement only if requested and within the agreed scope. Use the
   [infra-as-code skill](../infra-as-code/SKILL.md) and
   [CI/CD skill](../ci-cd/SKILL.md) for relevant implementation work, and the
   [security assessment skill](../security-assessment/SKILL.md) when assessing
   security risks. Follow the [TDD skill](../test-driven-development/SKILL.md)
   for behaviour changes and its process for exceptions.
6. Obtain explicit approval before accessing or changing shared or production
   systems or performing externally visible operations. Report decisions,
   evidence, checks, unresolved questions, and risks; do not claim unverified
   platform properties or deployment outcomes.
