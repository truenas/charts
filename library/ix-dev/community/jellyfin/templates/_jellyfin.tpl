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
    {{- include "jellyfin.storage.ci.migration" (dict "storage" .Values.jellyfinStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.jellyfinStorage.config) | nindent 4 }}
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: /config
  cache:
    enabled: true
    {{- include "jellyfin.storage.ci.migration" (dict "storage" .Values.jellyfinStorage.cache) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.jellyfinStorage.cache) | nindent 4 }}
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: /cache
  transcode:
    enabled: true
    {{- include "jellyfin.storage.ci.migration" (dict "storage" .Values.jellyfinStorage.transcodes) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.jellyfinStorage.transcodes) | nindent 4 }}
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: /config/transcodes
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
    {{- include "jellyfin.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      jellyfin:
        jellyfin:
          mountPath: {{ $storage.mountPath }}
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

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "jellyfin.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}

  {{- if (hasKey $storage "medium") -}}
    {{- $_ := set $storage "emptyDirConfig" dict -}}
    {{- $_ := set $storage.emptyDirConfig "medium" $storage.medium -}}
    {{- $_ := set $storage.emptyDirConfig "size" 1 -}}
  {{- end -}}
{{- end -}}
