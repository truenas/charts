{{- define "freshrss.workload" -}}
workload:
  freshrss:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.freshrssNetwork.hostNetwork }}
      securityContext:
        fsGroup: 33
      containers:
        freshrss:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 33
            runAsGroup: 33
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
              path: /i
            readiness:
              enabled: true
              type: http
              port: {{ .Values.freshrssNetwork.webPort }}
              path: /i
            startup:
              enabled: true
              type: http
              port: {{ .Values.freshrssNetwork.webPort }}
              path: /i
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 33
                                                        "GID" 33
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "02-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
