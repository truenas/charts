{{- define "bazarr.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "bazarr.storage.ci.migration" (dict "storage" .Values.bazarrStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.bazarrStorage.config) | nindent 4 }}
    targetSelector:
      bazarr:
        bazarr:
          mountPath: /config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      bazarr:
        bazarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.bazarrStorage.additionalStorages }}
  {{ printf "bazarr-%v:" (int $idx) }}
    enabled: true
    {{- include "bazarr.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      bazarr:
        bazarr:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "bazarr.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
