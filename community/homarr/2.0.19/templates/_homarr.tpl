{{- define "homarr.workload" -}}
workload:
  homarr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.homarrNetwork.hostNetwork }}
      containers:
        homarr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.homarrRunAs.user }}
            runAsGroup: {{ .Values.homarrRunAs.group }}
          env:
            PORT: {{ .Values.homarrNetwork.webPort }}
          envFrom:
            - secretRef:
                name: homarr-creds
          {{ with .Values.homarrConfig.additionalEnvs }}
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
              port: {{ .Values.homarrNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: http
              port: {{ .Values.homarrNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: http
              port: {{ .Values.homarrNetwork.webPort }}
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.homarrRunAs.user
                                                        "GID" .Values.homarrRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
