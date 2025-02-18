{{- define "jellyfin.workload" -}}
workload:
  jellyfin:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.jellyfinNetwork.hostNetwork }}
      containers:
        jellyfin:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.jellyfinRunAs.user }}
            runAsGroup: {{ .Values.jellyfinRunAs.group }}
          env:
            {{ with .Values.jellyfinConfig.publishedServerUrl }}
            JELLYFIN_PublishedServerUrl: {{ . | quote }}
            {{ end }}
          {{ with .Values.jellyfinConfig.additionalEnvs }}
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
              port: 8096
              path: /health
            readiness:
              enabled: true
              type: http
              port: 8096
              path: /health
            startup:
              enabled: true
              type: http
              port: 8096
              path: /health
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" (include "ix.v1.common.helper.makeIntOrNoop" .Values.jellyfinRunAs.user)
                                                        "GID" (include "ix.v1.common.helper.makeIntOrNoop" .Values.jellyfinRunAs.group)
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{/* Service */}}
service:
  jellyfin:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: jellyfin
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.jellyfinNetwork.webPort }}
        nodePort: {{ .Values.jellyfinNetwork.webPort }}
        targetPort: 8096
        targetSelector: jellyfin

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.jellyfinStorage.config) | nindent 4 }}
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: /config
        {{- if and (eq .Values.jellyfinStorage.config.type "ixVolume")
                  (not (.Values.jellyfinStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  cache:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.jellyfinStorage.cache) | nindent 4 }}
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: /cache
        {{- if and (eq .Values.jellyfinStorage.cache.type "ixVolume")
                  (not (.Values.jellyfinStorage.cache.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/cache
        {{- end }}
  transcode:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.jellyfinStorage.transcodes) | nindent 4 }}
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: /config/transcodes
        {{- if and (eq .Values.jellyfinStorage.transcodes.type "ixVolume")
                  (not (.Values.jellyfinStorage.transcodes.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/transcodes
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.jellyfinStorage.additionalStorages }}
  {{ printf "jellyfin-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

{{ with .Values.jellyfinGPU }}
scaleGPU:
  {{ range $key, $value := . }}
  - gpu:
      {{ $key }}: {{ $value }}
    targetSelector:
      jellyfin:
        - jellyfin
  {{ end }}
{{ end }}
{{- end -}}
