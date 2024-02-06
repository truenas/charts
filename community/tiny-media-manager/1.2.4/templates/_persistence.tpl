{{- define "tmm.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "tmm.storage.ci.migration" (dict "storage" .Values.tmmStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.tmmStorage.data) | nindent 4 }}
    targetSelector:
      tmm:
        tmm:
          mountPath: /data
  varlognginx:
    enabled: true
    type: emptyDir
    targetSelector:
      tmm:
        tmm:
          mountPath: /var/log/nginx/
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      tmm:
        tmm:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.tmmStorage.additionalStorages }}
  {{ printf "tmm-%v" (int $idx) }}:
    enabled: true
    {{- include "tmm.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      tmm:
        tmm:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "tmm.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
