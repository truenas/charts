{{- define "mealie.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.mealieStorage.data) | nindent 4 }}
    targetSelector:
      mealie:
        mealie:
          mountPath: /app/data
        {{- if eq .Values.mealieStorage.data.type "ixVolume" }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      mealie:
        mealie:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.mealieStorage.additionalStorages }}
  {{ printf "mealie-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      mealie:
        mealie:
          mountPath: {{ $storage.mountPath }}
        {{- if eq .Values.mealieStorage.data.type "ixVolume" }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end -}}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.mealieStorage.pgData
            "pgBackup" .Values.mealieStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
