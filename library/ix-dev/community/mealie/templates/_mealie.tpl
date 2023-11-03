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
            # TODO: Check if we can use arbitrary user IDs
            runAsUser: 911
            runAsGroup: 911
            readOnlyRootFilesystem: false
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
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "01-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
