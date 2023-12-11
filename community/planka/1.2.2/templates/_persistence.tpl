{{- define "planka.persistence" -}}
persistence:
  avatars:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.plankaStorage.avatars) | nindent 4 }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/public/user-avatars
  bg-img:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.plankaStorage.backgroundImages) | nindent 4 }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/public/project-background-images
  attachments:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.plankaStorage.attachments) | nindent 4 }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/private/attachments
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      planka:
        planka:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.plankaStorage.additionalStorages }}
  {{ printf "planka-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      planka:
        planka:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.plankaStorage.pgData
            "pgBackup" .Values.plankaStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
