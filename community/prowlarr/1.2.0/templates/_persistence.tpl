{{- define "prowlarr.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "prowlarr.storage.ci.migration" (dict "storage" .Values.prowlarrStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.prowlarrStorage.config) | nindent 4 }}
    targetSelector:
      prowlarr:
        prowlarr:
          mountPath: /config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      prowlarr:
        prowlarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.prowlarrStorage.additionalStorages }}
  {{ printf "prowlarr-%v:" (int $idx) }}
    enabled: true
    {{- include "prowlarr.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      prowlarr:
        prowlarr:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "prowlarr.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
