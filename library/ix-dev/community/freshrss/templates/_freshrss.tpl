{{- define "freshrss.workload" -}}
workload:
  freshrss:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.freshrssNetwork.hostNetwork }}
      containers:
        freshrss:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - SETGID
                - SETUID
          envFrom:
            - secretRef:
                name: freshrss-creds
            - configMapRef:
                name: freshrss-config
          {{ with .Values.freshrssConfig.additionalEnvs }}
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
              port: {{ .Values.freshrssNetwork.webPort }}
              path: /i/
            readiness:
              enabled: true
              type: http
              port: {{ .Values.freshrssNetwork.webPort }}
              path: /i/
            startup:
              enabled: true
              type: http
              port: {{ .Values.freshrssNetwork.webPort }}
              path: /i/
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "01-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
