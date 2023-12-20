{{- define "joplin.persistence" -}}
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
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
