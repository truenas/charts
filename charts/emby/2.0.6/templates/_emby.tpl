{{- define "emby.workload" -}}
workload:
  emby:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.embyNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.embyID.group }}
      containers:
        emby:
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
          fixedEnv:
            PUID: {{ .Values.embyID.user }}
          {{ if .Values.embyGPU }}
          env:
            GIDLIST: 44,107
          {{ end }}
          {{ with .Values.embyConfig.additionalEnvs }}
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
              path: /emby/System/Ping
              port: 8096
            readiness:
              enabled: true
              type: http
              path: /emby/System/Ping
              port: 8096
            startup:
              enabled: true
              type: http
              path: /emby/System/Ping
              port: 8096

{{ with .Values.embyGPU }}
scaleGPU:
  {{ range $key, $value := . }}
  - gpu:
      {{ $key }}: {{ $value }}
    targetSelector:
      emby:
        - emby
  {{ end }}
{{ end }}
{{- end -}}
