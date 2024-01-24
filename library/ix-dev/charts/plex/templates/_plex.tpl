{{- define "plex.workload" -}}
workload:
  plex:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.plexNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.plexID.group }}
      containers:
        plex:
          enabled: true
          primary: true
          imageSelector: {{ .Values.plexConfig.imageSelector }}
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            # readOnlyRootFilesystem: false
          env:
            PLEX_CLAIM: {{ .Values.plexConfig.claim }}
          fixedEnv:
            PUID: {{ .Values.plexID.user }}
            PLEX_UID: {{ .Values.plexID.user }}
            PLEX_GID: {{ .Values.plexID.group }}
          {{ with .Values.plexConfig.additionalEnvs }}
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
              port: 32400
            readiness:
              enabled: true
              type: tcp
              port: 32400
            startup:
              enabled: true
              type: tcp
              port: 32400

{{ with .Values.plexGPU }}
scaleGPU:
  {{ range $key, $value := . }}
  - gpu:
      {{ $key }}: {{ $value }}
    targetSelector:
      plex:
        - plex
  {{ end }}
{{ end }}
{{- end -}}
