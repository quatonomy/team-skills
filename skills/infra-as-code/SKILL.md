---
name: infra-as-code
description: "Use when designing, reviewing, implementing, or troubleshooting infrastructure as code, including Terraform, OpenTofu, Pulumi, Bicep, CloudFormation, infrastructure modules, state, drift, and plans."
---

# Infrastructure as code

Work from the engineer's intent and the relevant repository and environment
conventions. The engineer owns infrastructure and deployment decisions; do not
assume a provider, tool, account, environment, or desired architecture.

1. Clarify the desired infrastructure, scope, target environments, ownership,
   constraints, and expected outcomes. Inspect existing configuration, modules,
   versions, dependencies, tests, deployment processes, and documentation before
   proposing changes. Ask about material unknowns.
2. Assess the resource lifecycle and dependencies, state and locking, drift,
   migration, and rollback. Consider least privilege, secrets, network boundaries,
   availability, observability, quotas, and cost as applicable. Identify
   potentially destructive replacements, downtime, and data loss; distinguish
   verified facts from risks and assumptions.
3. For consequential choices, present practical options and trade-offs, recommend
   an approach, and obtain the engineer's decision. Reuse existing patterns and
   avoid speculative modules or provider-specific assumptions.
4. Make changes only within the requested scope. Use existing checks and tests;
   follow the [TDD skill](../test-driven-development/SKILL.md) for behaviour
   changes, including its process for exceptions. Use formatting, validation,
   static analysis, and isolated tests where suitable. Explain when a check
   cannot verify real infrastructure behaviour.
5. Before accessing remote state or cloud environments, running a plan that
   connects to them, or applying, importing, migrating, or destroying resources,
   agree on the exact target, credentials, scope, and potentially visible effects
   and obtain explicit approval. Treat plans and state as potentially sensitive;
   do not expose secrets or retain sensitive output. Do not treat a successful
   plan or validation as proof that an apply will succeed.
6. Report changes, commands and observed results, target environment, predicted
   impact, rollback considerations, and unresolved risks or unverified
   behaviour. Never claim a deployment or infrastructure state without evidence.
