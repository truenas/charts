{{- define "listmonk.persistence" -}}
persistence:
  uploads:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.listmonkStorage.uploads) | nindent 4 }}
    targetSelector:
      listmonk:
        listmonk:
          mountPath: /listmonk/uploads
        {{- if and (eq .Values.listmonkStorage.uploads.type "ixVolume")
                  (not (.Values.listmonkStorage.uploads.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/uploads
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      listmonk:
        listmonk:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.listmonkStorage.additionalStorages }}
  {{ printf "listmonk-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      listmonk:
        listmonk:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end -}}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.listmonkStorage.pgData
            "pgBackup" .Values.listmonkStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
