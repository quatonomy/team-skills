---
name: code-architecture
description: "Use when discussing, designing, implementing, or refactoring software architecture, code boundaries, and software design."
---

# Code architecture

The engineer owns architectural decisions. Work from their stated goals and the
relevant codebase, not OpenSpec artifacts. Apply principles to improve the
solution, not as rules that force patterns or abstractions.

1. Clarify the behaviour, constraints, and relevant quality attributes. Inspect
   existing code, interfaces, dependencies, tests, and local conventions before
   proposing changes.
2. Identify responsibilities, boundaries, dependencies, and likely sources of
   change. Consider cohesion, coupling, separation of concerns, and SOLID:
   single responsibility, open-closed, substitutability, interface segregation,
   and dependency inversion. Explain which principles matter and why; avoid
   speculative extensibility, needless layers, and pattern-driven design.
3. For consequential choices, present practical options, trade-offs, and a
   recommendation. Discuss testability, failure handling, security,
   performance, and maintenance as relevant. Ask the engineer to decide before
   making a significant architectural choice.
4. Define clear contracts and validate untrusted data at boundaries. Follow
   language and project conventions unless a deviation is justified and agreed.
   Keep implementation changes within the request.
5. Follow the [TDD skill](../test-driven-development/SKILL.md) for behaviour
   changes and establish a passing baseline for behaviour-preserving refactoring.
   Explain decisions, relevant checks, and any unresolved risks; do not claim
   guarantees beyond the available evidence.
