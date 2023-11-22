{{- define "planka.persistence" -}}
persistence:
  avatars:
    enabled: true
    {{- include "planka.storage.ci.migration" (dict "storage" .Values.plankaStorage.avatars) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.plankaStorage.avatars) | nindent 4 }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/public/user-avatars
  bg-img:
    enabled: true
    {{- include "planka.storage.ci.migration" (dict "storage" .Values.plankaStorage.backgroundImages) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.plankaStorage.backgroundImages) | nindent 4 }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/public/project-background-images
  attachments:
    enabled: true
    {{- include "planka.storage.ci.migration" (dict "storage" .Values.plankaStorage.attachments) }}
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
    {{- include "planka.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      planka:
        planka:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- include "planka.storage.ci.migration" (dict "storage" .Values.plankaStorage.pgData) }}
  {{- include "planka.storage.ci.migration" (dict "storage" .Values.plankaStorage.pgBackup) }}
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.plankaStorage.pgData
            "pgBackup" .Values.plankaStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "planka.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
