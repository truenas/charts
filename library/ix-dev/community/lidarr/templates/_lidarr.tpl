{{- define "lidarr.workload" -}}
workload:
  lidarr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.lidarrNetwork.hostNetwork }}
      containers:
        lidarr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.lidarrRunAs.user }}
            runAsGroup: {{ .Values.lidarrRunAs.group }}
          env:
            LIDARR__PORT: {{ .Values.lidarrNetwork.webPort }}
            LIDARR__INSTANCE_NAME: {{ .Values.lidarrConfig.instanceName }}
          {{ with .Values.lidarrConfig.additionalEnvs }}
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
              port: "{{ .Values.lidarrNetwork.webPort }}"
              path: /ping
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.lidarrNetwork.webPort }}"
              path: /ping
            startup:
              enabled: true
              type: http
              port: "{{ .Values.lidarrNetwork.webPort }}"
              path: /ping
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.lidarrRunAs.user
                                                        "GID" .Values.lidarrRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}

{{/* Service */}}
service:
  lidarr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: lidarr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.lidarrNetwork.webPort }}
        nodePort: {{ .Values.lidarrNetwork.webPort }}
        targetSelector: lidarr

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    type: {{ .Values.lidarrStorage.config.type }}
    datasetName: {{ .Values.lidarrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.lidarrStorage.config.hostPath | default "" }}
    targetSelector:
      lidarr:
        lidarr:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      lidarr:
        lidarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.lidarrStorage.additionalStorages }}
  {{ printf "lidarr-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      lidarr:
        lidarr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
