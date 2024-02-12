{{- define "mealie.workload" -}}
workload:
  mealie:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.mealieNetwork.hostNetwork }}
      containers:
        mealie:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.mealieRunAs.user }}
            runAsGroup: {{ .Values.mealieRunAs.group }}
            readOnlyRootFilesystem: false
          fixedEnv:
            PUID: {{ .Values.mealieRunAs.user }}
          envFrom:
            - secretRef:
                name: mealie
            - configMapRef:
                name: mealie
          {{ with .Values.mealieConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: exec
              command:
                - python
                - /app/mealie/scripts/healthcheck.py
            readiness:
              enabled: true
              type: exec
              command:
                - python
                - /app/mealie/scripts/healthcheck.py
            startup:
              enabled: true
              type: exec
              command:
                - python
                - /app/mealie/scripts/healthcheck.py
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.mealieRunAs.user
                                                        "GID" .Values.mealieRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "02-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
