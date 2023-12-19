{{- define "n8n.workload" -}}
workload:
  n8n:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.n8nNetwork.hostNetwork }}
      containers:
        n8n:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.n8nRunAs.user }}
            runAsGroup: {{ .Values.n8nRunAs.group }}
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          envFrom:
            - secretRef:
                name: n8n-creds
            - configMapRef:
                name: n8n-config
          {{ with .Values.n8nConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            {{ $prot := "http" }}
            {{ if .Values.n8nNetwork.certificateID }}
              {{ $prot = "https" }}
            {{ end }}
            liveness:
              enabled: true
              type: {{ $prot }}
              path: /healthz
              port: {{ .Values.n8nNetwork.webPort }}
            readiness:
              enabled: true
              type: {{ $prot }}
              path: /healthz
              port: {{ .Values.n8nNetwork.webPort }}
            startup:
              enabled: true
              type: {{ $prot }}
              path: /healthz
              port: {{ .Values.n8nNetwork.webPort }}
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                    "UID" .Values.n8nRunAs.user
                                                    "GID" .Values.n8nRunAs.group
                                                    "mode" "check"
                                                    "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.redisWait" (dict  "name" "02-redis-wait"
                                                      "secretName" "redis-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "03-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
