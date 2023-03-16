{{/* Returns a postgres pod with init container for fixing permissions
and a pre-upgrade job to backup the database */}}
{{/* Call this template:
{{ include "ix.v1.common.app.postgres" (dict "name" "postgres" "secretName" "postgres-creds" "backupPath" "/postgres_backup" "resources" .Values.resources) }}

name (optional): Name of the postgres pod/container (default: postgres)
secretName (required): Name of the secret containing the postgres credentials
backupPath (optional): Path to store the backup, it's the container's path (default: /postgres_backup)
resources (required): Resources for the postgres container
*/}}
{{- define "ix.v1.common.app.postgres" -}}
  {{- $name := .name | default "postgres" -}}
  {{- $secretName := (required "Postgres - Secret Name is required" .secretName) -}}
  {{- $backupPath := .backupPath | default "/postgres_backup" -}}
  {{- $resources := .resources }}
{{ $name }}:
  enabled: true
  type: Deployment
  podSpec:
    containers:
      {{ $name }}:
        enabled: true
        primary: true
        imageSelector: imagePostgres
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
          liveness:
            enabled: true
            type: exec
            command:
              - sh
              - -c
              - "until pg_isready -U ${POSTGRES_USER} -h localhost; do sleep 2; done"
          readiness:
            enabled: true
            type: exec
            command:
              - sh
              - -c
              - "until pg_isready -U ${POSTGRES_USER} -h localhost; do sleep 2; done"
          startup:
            enabled: true
            type: exec
            command:
              - sh
              - -c
              - "until pg_isready -U ${POSTGRES_USER} -h localhost; do sleep 2; done"
    initContainers:
    {{- include "ix.v1.common.app.permissions" (dict "UID" 999 "GID" 999) | nindent 6 }}
postgresbackup:
  enabled: true
  type: Job
  annotations:
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-weight": "1"
    "helm.sh/hook-delete-policy": hook-succeeded
  podSpec:
    restartPolicy: Never
    containers:
      postgresbackup:
        enabled: true
        primary: true
        imageSelector: imagePostgres
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
            until pg_isready -U ${POSTGRES_USER} -h ${POSTGRES_HOST}; do sleep 2; done
            echo "Creating backup of ${POSTGRES_DB} database"
            pg_dump --dbname=${POSTGRES_URL} --file {{ $backupPath }}/${POSTGRES_DB}_$(date +%Y-%m-%d_%H-%M-%S).sql || echo "Failed to create backup"
            echo "Backup finished"
    initContainers:
    {{- include "ix.v1.common.app.permissions" (dict "UID" 999 "GID" 999 "type" "init") | nindent 6 }}
{{- end -}}
