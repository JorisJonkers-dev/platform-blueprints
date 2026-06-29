# Gateway API Preview Pack

Reusable Gateway API preview primitives for deploy-v2 route experiments.

The pack defines a parameterized `GatewayClass` plus public and LAN `Gateway`
templates. Consumers own HTTPRoutes, ReferenceGrants, certificates, listener
hostnames, and controller-specific values. The pack is intentionally separate
from the Traefik parity route renderer so production cutover can stay unchanged.
