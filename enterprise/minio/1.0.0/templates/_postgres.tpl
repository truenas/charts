{{- define "postgres.workload" -}}
{{- if .Values.logsearch.enabled }}
workload:
  postgres:
    enabled: true
    type: Deployment
    podSpec:
      containers:
        postgres:
          enabled: true
          primary: true
          imageSelector: postgresImage
          securityContext:
            runAsUser: 999
            runAsGroup: 999
            readOnlyRootFilesystem: false
          resources:
            limits:
              cpu: {{ .Values.resources.limits.cpu }}
              memory: {{ .Values.resources.limits.memory }}
          envFrom:
            - secretRef:
                name: postgres-creds
            - configMapRef:
                name: postgres-config
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
      {{- include "minio.permissions" (dict "UID" 999 "GID" 999) | nindent 8 }}
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
          imageSelector: postgresImage
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
                name: postgres-creds
            - configMapRef:
                name: postgres-config
          command:
            - sh
            - -c
            - |
              until pg_isready -U ${POSTGRES_USER} -h ${POSTGRES_HOST}; do sleep 2; done
              echo "Creating backup of ${POSTGRES_DB} database"
              pg_dump --dbname=${POSTGRES_URL} --file /postgres_backup/${POSTGRES_DB}_$(date +%Y-%m-%d_%H-%M-%S).sql || echo "Failed to create backup"
              echo "Backup finished"
      initContainers:
      {{- include "minio.permissions" (dict "UID" 999 "GID" 999 "type" "init") | nindent 8 }}
  {{- end -}}
{{- end -}}
