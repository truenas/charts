{{- define "flame.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "flame.storage.ci.migration" (dict "storage" .Values.flameStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.flameStorage.data) | nindent 4 }}
    targetSelector:
      flame:
        flame:
          mountPath: /app/data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      flame:
        flame:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.flameStorage.additionalStorages }}
  {{ printf "flame-%v:" (int $idx) }}
    enabled: true
    {{- include "flame.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      flame:
        flame:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "flame.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
