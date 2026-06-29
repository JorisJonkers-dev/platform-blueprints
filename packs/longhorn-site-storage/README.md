# Longhorn Site Storage Pack

Reusable Longhorn primitives for deploy-v2 storage rendering.

The pack contains a parameterized Helm release, a retained StorageClass, and
recurring job templates for snapshot and backup policies. Every site-specific
value is a Flux substitution placeholder. Consumers own node contracts, disk
paths, tags, backup target credentials, PVC adoption, and state-move plans.

This pack is not a live storage migration. It must not be used to change a
production StorageClass or PVC without a consumer-owned move plan.
