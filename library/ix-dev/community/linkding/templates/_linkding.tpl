{{- define "linkding.workload" -}}
workload:
  linkding:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.linkdingNetwork.hostNetwork }}
      containers:
        linkding:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.linkdingRunAs.user }}
            runAsGroup: {{ .Values.linkdingRunAs.group }}
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
          envFrom:
            - secretRef:
                name: linkding
            - configMapRef:
                name: linkding
          {{ with .Values.linkdingConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: {{ .Values.linkdingNetwork.webPort }}
              path: /health
            readiness:
              enabled: true
              type: http
              port: {{ .Values.linkdingNetwork.webPort }}
              path: /health
            startup:
              enabled: true
              type: http
              port: {{ .Values.linkdingNetwork.webPort }}
              path: /health
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.linkdingRunAs.user
                                                        "GID" .Values.linkdingRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "02-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
