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
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - SETGID
                - SETUID
                - NET_BIND_SERVICE
                - KILL
          env:
            AUTOMATED_CONVERSION_OUTPUT_DIR: /output
            HANDBRAKE_GUI: "1"
            WEB_LISTENING_PORT: {{ .Values.handbrakeNetwork.webPort }}
            VNC_LISTENING_PORT: {{ .Values.handbrakeNetwork.vncPort }}
            VNC_PASSWORD: {{ .Values.handbrakeConfig.vncPassword }}
            DARK_MODE: {{ ternary "1" "0" .Values.handbrakeConfig.darkMode }}
            SECURE_CONNECTION: {{ ternary "1" "0" .Values.handbrakeConfig.secureConnection }}
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
              type: tcp
              port: {{ .Values.handbrakeNetwork.vncPort }}
            readiness:
              enabled: true
              type: tcp
              port: {{ .Values.handbrakeNetwork.vncPort }}
            startup:
              enabled: true
              type: tcp
              port: {{ .Values.handbrakeNetwork.vncPort }}
{{ with .Values.handbrakeGPU }}
scaleGPU:
  {{ range $key, $value := . }}
  - gpu:
      {{ $key }}: {{ $value }}
    targetSelector:
      handbrake:
        - handbrake
  {{ end }}
{{ end }}
{{- end -}}
