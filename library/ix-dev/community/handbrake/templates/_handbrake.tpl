{{- define "handbrake.workload" -}}
workload:
  handbrake:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.handbrakeNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.handbrakeID.group }}
      containers:
        handbrake:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
          env:
            AUTOMATED_CONVERSION_OUTPUT_DIR: /output
            WEB_LISTENING_PORT: {{ .Values.handbrakeNetwork.webPort }}
            VNC_LISTENING_PORT: {{ .Values.handbrakeNetwork.vncPort }}
            DARK_MODE: {{ ternary "1" "0" .Values.handbrakeConfig.darkMode }}
          fixedEnv:
            PUID: {{ .Values.handbrakeID.user }}
          {{ with .Values.handbrakeConfig.additionalEnvs }}
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
              port: {{ .Values.handbrakeNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: http
              port: {{ .Values.handbrakeNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: http
              port: {{ .Values.handbrakeNetwork.webPort }}
              path: /
{{- end -}}
