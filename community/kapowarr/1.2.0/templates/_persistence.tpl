{{- define "kapowarr.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "kapowarr.storage.ci.migration" (dict "storage" .Values.kapowarrStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.kapowarrStorage.config) | nindent 4 }}
    targetSelector:
      kapowarr:
        kapowarr:
          mountPath: /app/db
        {{- if and (eq .Values.kapowarrStorage.config.type "ixVolume")
                  (not (.Values.kapowarrStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  downloads:
    enabled: true
    {{- include "kapowarr.storage.ci.migration" (dict "storage" .Values.kapowarrStorage.downloads) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.kapowarrStorage.downloads) | nindent 4 }}
    targetSelector:
      kapowarr:
        kapowarr:
          mountPath: /app/temp_downloads
        {{- if and (eq .Values.kapowarrStorage.downloads.type "ixVolume")
                  (not (.Values.kapowarrStorage.downloads.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/downloads
        {{- end }}
  content:
    enabled: true
    {{- include "kapowarr.storage.ci.migration" (dict "storage" .Values.kapowarrStorage.content) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.kapowarrStorage.content) | nindent 4 }}
    targetSelector:
      kapowarr:
        kapowarr:
          mountPath: /content
        {{- if and (eq .Values.kapowarrStorage.content.type "ixVolume")
                  (not (.Values.kapowarrStorage.content.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/content
        {{- end }}
  {{- range $idx, $storage := .Values.kapowarrStorage.additionalStorages }}
  {{ printf "kapowarr-%v:" (int $idx) }}
    enabled: true
    {{- include "kapowarr.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      kapowarr:
        kapowarr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "kapowarr.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
