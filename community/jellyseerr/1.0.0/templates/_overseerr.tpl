{{- define "jellyseerr.workload" -}}
workload:
  jellyseerr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.jellyseerrNetwork.hostNetwork }}
      containers:
        jellyseerr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.jellyseerrRunAs.user }}
            runAsGroup: {{ .Values.jellyseerrRunAs.group }}
          env:
            PORT: {{ .Values.jellyseerrNetwork.webPort }}
          {{ with .Values.jellyseerrConfig.additionalEnvs }}
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
              port: {{ .Values.jellyseerrNetwork.webPort }}
              path: /api/v1/status
            readiness:
              enabled: true
              type: http
              port: {{ .Values.jellyseerrNetwork.webPort }}
              path: /api/v1/status
            startup:
              enabled: true
              type: http
              port: {{ .Values.jellyseerrNetwork.webPort }}
              path: /api/v1/status
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.jellyseerrRunAs.user
                                                        "GID" .Values.jellyseerrRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}

{{/* Service */}}
service:
  jellyseerr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: jellyseerr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.jellyseerrNetwork.webPort }}
        nodePort: {{ .Values.jellyseerrNetwork.webPort }}
        targetSelector: jellyseerr

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    type: {{ .Values.jellyseerrStorage.config.type }}
    datasetName: {{ .Values.jellyseerrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.jellyseerrStorage.config.hostPath | default "" }}
    targetSelector:
      jellyseerr:
        jellyseerr:
          mountPath: /app/config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      jellyseerr:
        jellyseerr:
          mountPath: /tmp
{{- end -}}
