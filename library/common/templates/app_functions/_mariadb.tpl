{{/* Returns a mariadb pod with init container for fixing permissions
and a pre-upgrade job to backup the database */}}
{{/* Call this template:
{{ include "ix.v1.common.app.mariadb" (dict "name" "mariadb" "secretName" "mariadb-creds" "backupPath" "/mariadb_backup" "resources" .Values.resources) }}

name (optional): Name of the mariadb pod/container (default: mariadb)
secretName (required): Name of the secret containing the mariadb credentials
backupPath (optional): Path to store the backup, it's the container's path (default: /mariadb_backup)
resources (required): Resources for the mariadb container
backupChownMode (optional): Whether to chown the backup directory or
          check parent directory permissions and fix them if needed.
          (default: check) Valid values: always, check
*/}}
{{- define "ix.v1.common.app.mariadb" -}}
  {{- $name := .name | default "mariadb" -}}
  {{- $secretName := (required "MariaDB - Secret Name is required" .secretName) -}}
  {{- $backupPath := .backupPath | default "/mariadb_backup" -}}
  {{- $backupChownMode := .backupChownMode | default "check" -}}
  {{- $ixChartContext := .ixChartContext -}}
  {{- $resources := (required "MariadDB - Resources are required" .resources) }}
{{ $name }}:
  enabled: true
  type: Deployment
  podSpec:
    containers:
      {{ $name }}:
        enabled: true
        primary: true
        imageSelector: mariadbImage
        securityContext:
          runAsUser: 999
          runAsGroup: 999
          readOnlyRootFilesystem: false
        resources:
          limits:
            cpu: {{ $resources.limits.cpu }}
            memory: {{ $resources.limits.memory }}
        envFrom:
          - secretRef:
              name: {{ $secretName }}
        probes:
          {{- $args := "--user=root --host=localhost --password=$MARIADB_ROOT_PASSWORD" }}
          liveness:
            enabled: true
            type: exec
            command:
              - sh
              - -c
              - "until mariadb-admin {{ $args }} ping && mariadb-admin {{ $args }} status; do sleep 2; done"
          readiness:
            enabled: true
            type: exec
            command:
              - sh
              - -c
              - "until mariadb-admin {{ $args }} ping && mariadb-admin {{ $args }} status; do sleep 2; done"
          startup:
            enabled: true
            type: exec
            command:
              - sh
              - -c
              - "until mariadb-admin {{ $args }} ping && mariadb-admin {{ $args }} status; do sleep 2; done"
    initContainers:
    {{- include "ix.v1.common.app.permissions" (dict "UID" 999 "GID" 999) | nindent 6 }}

{{/* Backup Job */}}
{{- $enableBackupJob := false -}}
{{- if hasKey $ixChartContext "isUpgrade" -}}
  {{- if $ixChartContext.isUpgrade -}}
    {{- $enableBackupJob = true -}}
    {{- if hasKey $ixChartContext "isStopped" -}}
      {{- if $ixChartContext.isStopped -}}
        {{- fail "Application must be running before upgrade. This is to ensure the database backup will be able to complete." -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- else -}}
  {{/*
    If the key is not present in ixChartContext,
    means we are outside SCALE (Probably CI),
    let upgrade job run
  */}}
  {{- $enableBackupJob = true -}}
{{- end }}
mariadbbackup:
  enabled: {{ $enableBackupJob }}
  type: Job
  annotations:
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-weight": "1"
    "helm.sh/hook-delete-policy": hook-succeeded
  podSpec:
    restartPolicy: Never
    containers:
      mariadbbackup:
        enabled: true
        primary: true
        imageSelector: mariadbImage
        securityContext:
          runAsUser: 999
          runAsGroup: 999
          readOnlyRootFilesystem: false
        probes:
          liveness:
            enabled: false
          readiness:
            enabled: false
          startup:
            enabled: false
        resources:
          limits:
            cpu: 2000m
            memory: 2Gi
        envFrom:
          - secretRef:
              name: {{ $secretName }}
        command:
          - sh
          - -c
          - |
            until mariadb-admin --user=root --host="${MARIADB_HOST}" --password="${MARIADB_ROOT_PASSWORD}" --connect-timeout=5 ping
              do
                echo "Waiting for mariadb to be ready. Sleeping 2 seconds"
                sleep 2s
            done
            until mariadb-admin --user=root --host="${MARIADB_HOST}" --password="${MARIADB_ROOT_PASSWORD}" --connect-timeout=5 status
              do
                echo "Waiting for mariadb to be alive. Sleeping 2 seconds"
                sleep 2s
            done

            echo "Creating backup of ${MARIADB_DATABASE} database"

            mariadb-dump ${MARIADB_DATABASE} --host="${MARIADB_HOST}" \
                         --user=root --password="${MARIADB_ROOT_PASSWORD}" \
                         > {{ $backupPath }}/${MARIADB_DATABASE}_$(date +%Y-%m-%d_%H-%M-%S).sql \
                         || echo "Failed to create backup"

            echo "Backup finished"
    initContainers:
    {{- include "ix.v1.common.app.permissions" (dict "UID" 999 "GID" 999 "type" "init" "mode" $backupChownMode) | nindent 6 }}
{{- end -}}


{{/* Returns a mariadb-wait container for waiting for mariadb to be ready */}}
{{/* Call this template:
{{ include "ix.v1.common.app.mariadbWait" (dict "name" "mariadb-wait" "secretName" "mariadb-creds") }}

name (optional): Name of the mariadb-wait container (default: mariadb-wait)
secretName (required): Name of the secret containing the mariadb credentials
*/}}
{{- define "ix.v1.common.app.mariadbWait" -}}
  {{- $name := .name | default "mariadb-wait" -}}
  {{- $secretName := (required "Mariadb-Wait - Secret Name is required" .secretName) }}
{{ $name }}:
  enabled: true
  type: init
  imageSelector: mariadbImage
  envFrom:
    - secretRef:
        name: {{ $secretName }}
  resources:
    limits:
      cpu: 500m
      memory: 256Mi
  command: bash
  args:
    - -c
    - |
      echo "Waiting for mariadb to be ready"
      until mariadb-admin --user=root --host="${MARIADB_HOST}" --password="${MARIADB_ROOT_PASSWORD}" --connect-timeout=5 ping
        do
          echo "Waiting for mariadb to be ready. Sleeping 2 seconds"
          sleep 2s
      done
      until mariadb-admin --user=root --host="${MARIADB_HOST}" --password="${MARIADB_ROOT_PASSWORD}" --connect-timeout=5 status
        do
          echo "Waiting for mariadb to be alive. Sleeping 2 seconds"
          sleep 2s
      done
{{- end -}}
