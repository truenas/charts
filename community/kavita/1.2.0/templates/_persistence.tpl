{{- define "kavita.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "kavita.storage.ci.migration" (dict "storage" .Values.kavitaStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.kavitaStorage.config) | nindent 4 }}
    targetSelector:
      kavita:
        kavita:
          mountPath: /kavita/config

  {{- range $idx, $storage := .Values.kavitaStorage.additionalStorages }}
  {{ printf "kavita-%v:" (int $idx) }}
    enabled: true
    {{- include "kavita.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      kavita:
        kavita:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "kavita.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
