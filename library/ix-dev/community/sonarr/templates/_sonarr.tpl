{{- define "sonarr.workload" -}}
workload:
  sonarr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.sonarrNetwork.hostNetwork }}
      containers:
        sonarr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.sonarrRunAs.user }}
            runAsGroup: {{ .Values.sonarrRunAs.group }}
          {{ with .Values.sonarrConfig.additionalEnvs }}
          env:
            {{ range $env := . }}
            {{ $env.name }}: {{ $env.value }}
            {{ end }}
          {{ end }}
          env:
            SONARR__PORT: {{ .Values.sonarrNetwork.webPort }}
            SONARR__INSTANCE_NAME: {{ .Values.sonarrConfig.instanceName }}
          probes:
            liveness:
              enabled: true
              type: http
              port: "{{ .Values.sonarrNetwork.webPort }}"
              path: /ping
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.sonarrNetwork.webPort }}"
              path: /ping
            startup:
              enabled: true
              type: http
              port: "{{ .Values.sonarrNetwork.webPort }}"
              path: /ping
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.sonarrRunAs.user
                                                        "GID" .Values.sonarrRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}

{{/* Service */}}
service:
  sonarr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: sonarr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.sonarrNetwork.webPort }}
        nodePort: {{ .Values.sonarrNetwork.webPort }}
        targetSelector: sonarr

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    type: {{ .Values.sonarrStorage.config.type }}
    datasetName: {{ .Values.sonarrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.sonarrStorage.config.hostPath | default "" }}
    targetSelector:
      sonarr:
        sonarr:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  {{- range $idx, $storage := .Values.sonarrStorage.additionalStorages }}
  {{ printf "sonarr-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      sonarr:
        sonarr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
