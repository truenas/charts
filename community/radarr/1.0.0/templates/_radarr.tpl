{{- define "radarr.workload" -}}
workload:
  radarr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.radarrNetwork.hostNetwork }}
      containers:
        radarr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.radarrRunAs.user }}
            runAsGroup: {{ .Values.radarrRunAs.group }}
          {{ with .Values.radarrConfig.additionalEnvs }}
          env:
            {{ range $env := . }}
            {{ $env.name }}: {{ $env.value }}
            {{ end }}
          {{ end }}
          env:
            RADARR__PORT: {{ .Values.radarrNetwork.webPort }}
            RADARR__INSTANCE_NAME: {{ .Values.radarrConfig.instanceName }}
          probes:
            liveness:
              enabled: true
              type: http
              port: "{{ .Values.radarrNetwork.webPort }}"
              path: /
              # FIXME: Next release will include this endpoint without auth
              # path: /ping
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.radarrNetwork.webPort }}"
              path: /
              # path: /ping
            startup:
              enabled: true
              type: http
              port: "{{ .Values.radarrNetwork.webPort }}"
              path: /
              # path: /ping
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.radarrRunAs.user
                                                        "GID" .Values.radarrRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}

{{/* Service */}}
service:
  radarr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: radarr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.radarrNetwork.webPort }}
        nodePort: {{ .Values.radarrNetwork.webPort }}
        targetSelector: radarr

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    type: {{ .Values.radarrStorage.config.type }}
    datasetName: {{ .Values.radarrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.radarrStorage.config.hostPath | default "" }}
    targetSelector:
      radarr:
        radarr:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      radarr:
        radarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.radarrStorage.additionalStorages }}
  {{ printf "radarr-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      radarr:
        radarr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
