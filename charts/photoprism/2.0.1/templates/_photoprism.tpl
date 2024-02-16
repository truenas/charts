{{- define "photoprism.workload" -}}
workload:
  photoprism:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.photoprismNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.photoprismID.group }}
      containers:
        photoprism:
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
                - FOWNER
                - DAC_OVERRIDE
                - SETGID
                - SETUID
                - KILL
          env:
            PHOTOPRISM_HTTP_PORT: {{ .Values.photoprismNetwork.webPort }}
            PHOTOPRISM_ADMIN_PASSWORD: {{ .Values.photoprismConfig.password }}
            PHOTOPRISM_PUBLIC: {{ .Values.photoprismConfig.public }}
            PHOTOPRISM_UID: {{ .Values.photoprismID.user }}
            PHOTOPRISM_GID: {{ .Values.photoprismID.group }}
            PHOTOPRISM_STORAGE_PATH: /photoprism/storage
            PHOTOPRISM_ORIGINALS_PATH: /photoprism/originals
            PHOTOPRISM_IMPORT_PATH: /photoprism/import
          fixedEnv:
            PUID: {{ .Values.photoprismID.user }}
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
