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
              values: {{ $env.value }}
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
                                                        "UID" .Values.jellyfinRunAs.user
                                                        "GID" .Values.jellyfinRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}

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
    type: {{ .Values.jellyfinStorage.config.type }}
    datasetName: {{ .Values.jellyfinStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.jellyfinStorage.config.hostPath | default "" }}
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  cache:
    enabled: true
    type: {{ .Values.jellyfinStorage.cache.type }}
    datasetName: {{ .Values.jellyfinStorage.cache.datasetName | default "" }}
    hostPath: {{ .Values.jellyfinStorage.cache.hostPath | default "" }}
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: /cache
        01-permissions:
          mountPath: /mnt/directories/cache
  transcode:
    enabled: true
    type: {{ .Values.jellyfinStorage.transcodes.type }}
    datasetName: {{ .Values.jellyfinStorage.transcodes.datasetName | default "" }}
    hostPath: {{ .Values.jellyfinStorage.transcodes.hostPath | default "" }}
    medium: {{ .Values.jellyfinStorage.transcodes.medium | default "" }}
    {{/* Size of the emptyDir */}}
    size: {{ .Values.jellyfinStorage.transcodes.size | default "" }}
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: /config/transcodes
        {{ if ne .Values.jellyfinStorage.transcodes.type "emptyDir" }}
        01-permissions:
          mountPath: /mnt/directories/transcodes
        {{ end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.jellyfinStorage.additionalStorages }}
  {{ printf "jellyfin-%v" (int $idx) }}:
    {{- $size := "" -}}
    {{- if $storage.size -}}
      {{- $size = (printf "%vGi" $storage.size) -}}
    {{- end }}
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    server: {{ $storage.server | default "" }}
    share: {{ $storage.share | default "" }}
    domain: {{ $storage.domain | default "" }}
    username: {{ $storage.username | default "" }}
    password: {{ $storage.password | default "" }}
    size: {{ $size }}
    {{- if eq $storage.type "smb-pv-pvc" }}
    mountOptions:
      - key: noperm
    {{- end }}
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
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
