{{- define "autobrr.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "autobrr.storage.ci.migration" (dict "storage" .Values.autobrrStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.autobrrStorage.config) | nindent 4 }}
    targetSelector:
      autobrr:
        autobrr:
          mountPath: /config
        {{- if and (eq .Values.autobrrStorage.config.type "ixVolume") (not .Values.autobrrStorage.config.ixVolumeConfig.aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      autobrr:
        autobrr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.autobrrStorage.additionalStorages }}
  {{ printf "autobrr-%v:" (int $idx) }}
    enabled: true
    {{- include "autobrr.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      autobrr:
        autobrr:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not $storage.ixVolumeConfig.aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "autobrr.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
