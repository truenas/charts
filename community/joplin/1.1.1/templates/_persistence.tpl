{{- define "joplin.persistence" -}}
  {{- include "joplin.storage.ci.migration" (dict "storage" .Values.joplinStorage.pgData) }}
  {{- include "joplin.storage.ci.migration" (dict "storage" .Values.joplinStorage.pgBackup) }}

persistence:
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.joplinStorage.pgData
            "pgBackup" .Values.joplinStorage.pgBackup
      ) | nindent 2 }}

  {{- range $idx, $storage := .Values.joplinStorage.additionalStorages }}
  {{ printf "joplin-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      joplin:
        joplin:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}


{{/* TODO: Remove on the next version bump, eg 1.1.0+ */}}
{{- define "joplin.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
