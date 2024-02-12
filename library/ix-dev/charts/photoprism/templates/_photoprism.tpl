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
          securityContext:
            runAsUser: {{ .Values.photoprismRunAs.user }}
            runAsGroup: {{ .Values.photoprismRunAs.group }}
            readOnlyRootFilesystem: false
          env:
            PHOTOPRISM_HTTP_PORT: {{ .Values.photoprismNetwork.webPort }}
            PHOTOPRISM_ADMIN_PASSWORD: {{ .Values.photoprismConfig.password }}
            PHOTOPRISM_PUBLIC: {{ .Values.photoprismConfig.public }}
            PHOTOPRISM_UID: {{ .Values.photoprismRunAs.user }}
            PHOTOPRISM_GID: {{ .Values.photoprismRunAs.group }}
            PHOTOPRISM_STORAGE_PATH: /photoprism/storage
            PHOTOPRISM_ORIGINALS_PATH: /photoprism/originals
            PHOTOPRISM_IMPORT_PATH: /photoprism/import
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
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.photoprismRunAs.user
                                                        "GID" .Values.photoprismRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
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
