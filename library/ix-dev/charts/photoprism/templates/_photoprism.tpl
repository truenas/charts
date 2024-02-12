{{- define "photoprism.workload" -}}
workload:
  photoprism:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.photoprismNetwork.hostNetwork }}
      containers:
        photoprism:
          enabled: true
          primary: true
          imageSelector: image
          # securityContext:
          #   runAsUser: 0
          #   runAsGroup: 0
          #   runAsNonRoot: false
          #   readOnlyRootFilesystem: false
          #   capabilities:
          #     add:
          #       - CHOWN
          #       - DAC_OVERRIDE
          #       - FOWNER
          #       - NET_BIND_SERVICE
          #       - NET_RAW
          env:
            PHOTOPRISM_HTTP_PORT: {{ .Values.photoprismNetwork.webPort }}
            PHOTOPRISM_ADMIN_PASSWORD: {{ .Values.photoprismConfig.password }}
            PHOTOPRISM_PUBLIC: {{ .Values.photoprismConfig.public }}
          {{ with .Values.photoprismConfig.additionalEnvs }}
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
              path: /
              port: {{ .Values.photoprismNetwork.webPort }}
            readiness:
              enabled: true
              type: http
              path: /
              port: {{ .Values.photoprismNetwork.webPort }}
            startup:
              enabled: true
              type: http
              path: /
              port: {{ .Values.photoprismNetwork.webPort }}

{{ with .Values.photoprismGPU }}
scaleGPU:
  {{ range $key, $value := . }}
  - gpu:
      {{ $key }}: {{ $value }}
    targetSelector:
      photoprism:
        - photoprism
  {{ end }}
{{ end }}
{{- end -}}
