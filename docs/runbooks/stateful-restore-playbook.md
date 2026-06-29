# Generic Stateful Restore Playbook

This playbook shows how to compose the restore primitives without encoding a
specific environment. Consumers own the real namespaces, PVC names, service
names, host paths, images, snapshot names, credentials, and rollback records.

## Preconditions

1. Point `kubectl` at the target cluster.
2. Stop writers for each stateful service before restoring.
3. Record backup artifact names, snapshot names, and checksums in the change
   record.
4. Confirm target namespaces, PVCs, and service pods already exist.
5. Keep pre-restore artifacts available until validation and rollback checks
   pass.

## Verify Inputs

```bash
scripts/restore/verify-restore-run.sh \
  --backup-run-dir /path/to/backup-run \
  --required-archive primary/example-service \
  --required-snapshot vault-raft
```

## PVC Archive Restore

```bash
scripts/restore/restore-pvc-archive.sh \
  --namespace "${TARGET_NAMESPACE}" \
  --pvc "${TARGET_PVC}" \
  --archive /path/to/backup-run/primary/example-service.tar.gz \
  --image "${RESTORE_IMAGE}" \
  --strip-components 1 \
  --wipe-target
```

Use `--pvc-match` only from a consumer wrapper after listing actual PVC names.

## Host-Path Archive Restore

```bash
scripts/restore/restore-hostpath-archive.sh \
  --ssh-target "${RESTORE_SSH_TARGET}" \
  --ssh-port "${RESTORE_SSH_PORT}" \
  --identity-file "${RESTORE_SSH_IDENTITY_FILE}" \
  --target-path "${TARGET_HOST_PATH}" \
  --archive /path/to/backup-run/primary/example-hostpath.tar.gz \
  --strip-components 1 \
  --wipe-target
```

## Vault Raft Snapshot Restore

```bash
export VAULT_TOKEN="$(cat)"

scripts/restore/restore-vault-raft-snapshot.sh \
  --namespace "${VAULT_NAMESPACE}" \
  --pod "${VAULT_POD}" \
  --container "${VAULT_CONTAINER}" \
  --snapshot /path/to/backup-run/snapshots/vault-raft.snapshot

unset VAULT_TOKEN
```

After a raft restore, re-run the consumer-owned Vault bootstrap or auth
configuration step for the target cluster.

## HTTP API Export Import

For services with an HTTP import API, port-forward the service and post the
caller-owned export file:

```bash
export API_IMPORT_USER="$(cat /path/to/user)"
export API_IMPORT_PASSWORD="$(cat /path/to/password)"

scripts/restore/restore-http-api-export.sh \
  --namespace "${SERVICE_NAMESPACE}" \
  --service "${SERVICE_NAME}" \
  --remote-port "${SERVICE_API_PORT}" \
  --path "${SERVICE_IMPORT_PATH}" \
  --input /path/to/backup-run/snapshots/service-export.json \
  --username-env API_IMPORT_USER \
  --password-env API_IMPORT_PASSWORD

unset API_IMPORT_USER API_IMPORT_PASSWORD
```

For a RabbitMQ definitions import, the consumer would usually pass
`--remote-port 15672 --path /api/definitions`. Credentials and service names
remain consumer-owned.

## Validation Record

Record one row per service:

```text
date	service	archive_or_snapshot	restore_result	rollback_result	operator
```

Do not commit the filled record if it contains real hostnames, namespaces,
service names, domains, secret names, or credential material.
