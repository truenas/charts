{{- define "planka.persistence" -}}
persistence:
  avatars:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.plankaStorage.avatars) | nindent 4 }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/public/user-avatars
        {{- if and (eq .Values.plankaStorage.avatars.type "ixVolume")
                  (not (.Values.plankaStorage.avatars.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/avatars
        {{- end }}
  bg-img:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.plankaStorage.backgroundImages) | nindent 4 }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/public/project-background-images
        {{- if and (eq .Values.plankaStorage.backgroundImages.type "ixVolume")
                  (not (.Values.plankaStorage.backgroundImages.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/backgroundImages
        {{- end }}
  attachments:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.plankaStorage.attachments) | nindent 4 }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/private/attachments
        {{- if and (eq .Values.plankaStorage.attachments.type "ixVolume")
                  (not (.Values.plankaStorage.attachments.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/attachments
        {{- end }}
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
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.plankaStorage.pgData
            "pgBackup" .Values.plankaStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
