{{- define "pal.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "pal.storage.ci.migration" (dict "storage" .Values.palStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.palStorage.config) | nindent 4 }}
    targetSelector:
      pal:
        pal:
          mountPath: /config
        {{- if and (eq .Values.palStorage.config.type "ixVolume")
                  (not (.Values.palStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      pal:
        pal:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.palStorage.additionalStorages }}
  {{ printf "pal-%v:" (int $idx) }}
    enabled: true
    {{- include "pal.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      pal:
        pal:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "pal.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
