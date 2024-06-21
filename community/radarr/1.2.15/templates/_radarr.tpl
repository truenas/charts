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
          env:
            RADARR__SERVER__PORT: {{ .Values.radarrNetwork.webPort }}
            RADARR__APP__INSTANCENAME: {{ .Values.radarrConfig.instanceName }}
          {{ with .Values.radarrConfig.additionalEnvs }}
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
              port: "{{ .Values.radarrNetwork.webPort }}"
              path: /ping
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.radarrNetwork.webPort }}"
              path: /ping
            startup:
              enabled: true
              type: http
              port: "{{ .Values.radarrNetwork.webPort }}"
              path: /ping
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.radarrRunAs.user
                                                        "GID" .Values.radarrRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}

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
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.radarrStorage.config) | nindent 4 }}
    targetSelector:
      radarr:
        radarr:
          mountPath: /config
        {{- if and (eq .Values.radarrStorage.config.type "ixVolume")
                  (not (.Values.radarrStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      radarr:
        radarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.radarrStorage.additionalStorages }}
  {{ printf "radarr-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      radarr:
        radarr:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
