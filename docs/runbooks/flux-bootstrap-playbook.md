# Generic Flux Bootstrap Playbook

This playbook describes a first Flux install when controller manifests and the
sync manifests are already committed to the caller repository. It avoids
`flux bootstrap` so protected branches do not need a direct push exception.

## Caller Inputs

- `FLUX_SYSTEM_PATH`: path to the caller-owned `flux-system` kustomization.
- `GIT_REPOSITORY_URL`: read-only Git URL for the caller-owned repository.
- `GIT_USERNAME`: Git username for the read-only credential.
- `GIT_TOKEN`: short-lived read-only token supplied from a shell prompt or
  secret manager, never committed.
- `KUBECONFIG`: kubeconfig for the target cluster.

## One-Time Install

```bash
export KUBECONFIG=/path/to/cluster.kubeconfig
export FLUX_SYSTEM_PATH=cluster/flux/clusters/example/flux-system
export GIT_REPOSITORY_URL=https://github.com/example-org/example-deploy.git
export GIT_USERNAME=example-bot

kubectl apply -k "${FLUX_SYSTEM_PATH}"

GIT_TOKEN="$(cat)"
flux create secret git flux-system \
  --url="${GIT_REPOSITORY_URL}" \
  --username="${GIT_USERNAME}" \
  --password="${GIT_TOKEN}"
unset GIT_TOKEN

flux check
flux get sources git -A
flux get kustomizations -A
```

## Upgrade

Regenerate controller manifests in a normal pull request:

```bash
flux install --export > "${FLUX_SYSTEM_PATH}/gotk-components.yaml"
```

After merge, Flux reconciles its own controllers from the committed manifests.

## Secret Rotation

```bash
kubectl -n flux-system delete secret flux-system

GIT_TOKEN="$(cat)"
flux create secret git flux-system \
  --url="${GIT_REPOSITORY_URL}" \
  --username="${GIT_USERNAME}" \
  --password="${GIT_TOKEN}"
unset GIT_TOKEN

flux reconcile source git flux-system
```

Keep concrete repository names, branches, token names, and cluster paths in the
consumer repository.
