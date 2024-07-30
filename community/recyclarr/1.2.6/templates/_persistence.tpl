{{- define "recyclarr.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "recyclarr.storage.ci.migration" (dict "storage" .Values.recyclarrStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.recyclarrStorage.config) | nindent 4 }}
    targetSelector:
      recyclarr:
        recyclarr:
          mountPath: /config
        {{- if and (eq .Values.recyclarrStorage.config.type "ixVolume")
                  (not (.Values.recyclarrStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      recyclarr:
        recyclarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.recyclarrStorage.additionalStorages }}
  {{ printf "recyclarr-%v" (int $idx) }}:
    enabled: true
    {{- include "recyclarr.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      recyclarr:
        recyclarr:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "recyclarr.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
