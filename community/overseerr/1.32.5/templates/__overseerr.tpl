{{- define "overseerr.workload" -}}
workload:
  overseerr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.overseerrNetwork.hostNetwork }}
      containers:
        overseerr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.overseerrRunAs.user }}
            runAsGroup: {{ .Values.overseerrRunAs.group }}
          env:
            OVERSEERR__PORT: {{ .Values.overseerrNetwork.webPort }}
            OVERSEERR__INSTANCE_NAME: {{ .Values.overseerrConfig.instanceName }}
          {{ with .Values.overseerrConfig.additionalEnvs }}
            {{ range $env := . }}
            {{ $env.name }}: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: "{{ .Values.overseerrNetwork.webPort }}"
              path: /ping
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.overseerrNetwork.webPort }}"
              path: /ping
            startup:
              enabled: true
              type: http
              port: "{{ .Values.overseerrNetwork.webPort }}"
              path: /ping
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.overseerrRunAs.user
                                                        "GID" .Values.overseerrRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}

{{/* Service */}}
service:
  overseerr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: overseerr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.overseerrNetwork.webPort }}
        nodePort: {{ .Values.overseerrNetwork.webPort }}
        targetSelector: overseerr

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    type: {{ .Values.overseerrStorage.config.type }}
    datasetName: {{ .Values.overseerrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.overseerrStorage.config.hostPath | default "" }}
    targetSelector:
      overseerr:
        overseerr:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      overseerr:
        overseerr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.overseerrStorage.additionalStorages }}
  {{ printf "overseerr-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      overseerr:
        overseerr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}