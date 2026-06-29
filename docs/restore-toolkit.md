# Restore Toolkit

`scripts/restore` contains generic restore primitives that pair with the backup
toolkit in `scripts/backup`. The backup scripts create portable artifacts and
metadata; the restore scripts validate those artifacts and stream them into
caller-supplied destinations.

Consumer repositories should keep fixed wrappers, service names, namespaces, PVC
names, hostnames, image choices, paths, and credentials outside this repository.

## Backup to Restore Flow

1. Capture host-path archives with `scripts/backup/backup-service-state.sh`.
2. Capture service-native exports with `scripts/backup/backup-service-snapshots.sh`.
3. Verify the backup run with `scripts/backup/verify-backup-run.sh`.
4. Before restore, verify required inputs with `scripts/restore/verify-restore-run.sh`.
5. Restore host-path archives with `scripts/restore/restore-hostpath-archive.sh`.
6. Restore PVC archives with `scripts/restore/restore-pvc-archive.sh`.
7. Restore service-native snapshots with `scripts/restore/restore-service-snapshots.sh`.
8. Restore Vault raft snapshots with `scripts/restore/restore-vault-raft-snapshot.sh`.
9. Import HTTP API exports with `scripts/restore/restore-http-api-export.sh`.

## Primitive Inputs

### `restore-hostpath-archive.sh`

Required inputs:

- `--ssh-target <user@host>`
- `--target-path <dir>`
- `--archive <file.tar.gz>`

Optional inputs:

- `--ssh-port <port>`
- `--identity-file <path>`
- `--ssh-opts "<opts>"`
- `--sudo "<cmd>"`
- `--strip-components <n>`
- `--wipe-target`
- `--dry-run`

### `restore-pvc-archive.sh`

Required inputs:

- `--namespace <ns>`
- `--pvc <name>` or `--pvc-match <substring>`
- `--archive <file.tar.gz>`
- `--image <image>`

Optional inputs:

- `--strip-components <n>`
- `--pod-name <name>`
- `--kubectl <path>`
- `--wipe-target`
- `--keep-pod`
- `--dry-run`
- `--print-manifest`

Use `--pvc` for offline validation. `--pvc-match` performs a live `kubectl`
lookup and is intended for consumer wrappers.

### `restore-service-snapshots.sh`

Required inputs:

- `--plugins <plugins.tsv>`
- `--snapshot-dir <dir>` unless using `--list`

Plugin columns:

```text
artifact	input_file	required	command_path	description
```

Each `command_path` is a caller-owned executable invoked as:

```text
command_path <snapshot-dir>/<input_file>
```

The command owns service-specific details such as namespaces, ports, API paths,
credentials, and import flags.

### `restore-vault-raft-snapshot.sh`

Required inputs:

- `--snapshot <vault-raft.snapshot>`
- `--namespace <ns>`
- `--pod <name>`

Optional inputs:

- `--container <name>`
- `--vault-addr <url>`
- `--vault-token-env <name>`
- `--vault-token-file <path>`
- `--kubectl <path>`
- `--dry-run`

The script reads the Vault token from an environment variable or token file at
execution time. It does not embed a namespace, pod name, token, Vault path, or
bootstrap command.

### `restore-http-api-export.sh`

Required inputs:

- `--input <file>`
- `--namespace <ns>`
- `--service <name>`
- `--remote-port <port>`
- `--path <path>`

Optional inputs:

- `--local-port <port>`
- `--scheme http|https`
- `--method <method>`
- `--content-type <value>`
- `--username-env <name>` and `--password-env <name>`
- `--username-file <path>` and `--password-file <path>`
- `--no-auth`
- `--kubectl <path>`
- `--curl <path>`
- `--dry-run`

The script port-forwards a caller-owned Kubernetes Service and posts the input
file to the caller-owned API path. For example, a consumer can use it for a
RabbitMQ definitions import by passing that service's namespace, service name,
management port, `/api/definitions`, and credentials from environment variables
or files.

### `verify-restore-run.sh`

Required inputs:

- `--backup-run-dir <dir>`

Optional inputs:

- `--required-archive <group/service>`
- `--required-snapshot <artifact>`

The verifier checks `archives.tsv`, optional `service-snapshots.tsv`, and
checksum files from the backup toolkit without contacting a cluster.

## Boundary

This repository only provides parameterized primitives. Fixed restore wrappers
belong in consumer repositories because they encode deployment-specific
namespaces, PVC names, host paths, image prefixes, service endpoints, and
credentials.
