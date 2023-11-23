{{- define "firefly.persistence" -}}
persistence:
  uploads:
    enabled: true
    {{- include "firefly.storage.ci.migration" (dict "storage" .Values.fireflyStorage.uploads) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.fireflyStorage.uploads) | nindent 4 }}
    targetSelector:
      firefly:
        firefly:
          mountPath: /var/www/html/storage/upload
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      firefly:
        firefly:
          mountPath: /tmp
      firefly-importer:
        firefly-importer:
          mountPath: /tmp

  {{- range $idx, $storage := .Values.fireflyStorage.additionalStorages }}
  {{ printf "firefly-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      firefly:
        firefly:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- include "firefly.storage.ci.migration" (dict "storage" .Values.fireflyStorage.pgData) }}
  {{- include "firefly.storage.ci.migration" (dict "storage" .Values.fireflyStorage.pgBackup) }}
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.fireflyStorage.pgData
            "pgBackup" .Values.fireflyStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.1.0+ */}}
{{- define "firefly.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
