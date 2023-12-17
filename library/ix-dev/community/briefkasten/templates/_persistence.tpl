{{- define "briefkasten.persistence" -}}
persistence:
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      briefkasten:
        briefkasten:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.briefkastenStorage.additionalStorages }}
  {{ printf "briefkasten-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      briefkasten:
        briefkasten:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end -}}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.briefkastenStorage.pgData
            "pgBackup" .Values.briefkastenStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
