{{- define "planka.persistence" -}}
persistence:
  avatars:
    enabled: true
    type: {{ .Values.plankaStorage.avatars.type }}
    datasetName: {{ .Values.plankaStorage.avatars.datasetName | default "" }}
    hostPath: {{ .Values.plankaStorage.avatars.hostPath | default "" }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/public/user-avatars
        01-permissions:
          mountPath: /mnt/directories/user-avatars
  bg-img:
    enabled: true
    type: {{ .Values.plankaStorage.backgroundImages.type }}
    datasetName: {{ .Values.plankaStorage.backgroundImages.datasetName | default "" }}
    hostPath: {{ .Values.plankaStorage.backgroundImages.hostPath | default "" }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/public/project-background-images
        01-permissions:
          mountPath: /mnt/directories/project-background-images
  attachments:
    enabled: true
    type: {{ .Values.plankaStorage.attachments.type }}
    datasetName: {{ .Values.plankaStorage.attachments.datasetName | default "" }}
    hostPath: {{ .Values.plankaStorage.attachments.hostPath | default "" }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/private/attachments
        01-permissions:
          mountPath: /mnt/directories/attachments
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      planka:
        planka:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.plankaStorage.additionalStorages }}
  {{ printf "planka-%v" (int $idx) }}:
    {{- $size := "" -}}
    {{- if $storage.size -}}
      {{- $size = (printf "%vGi" $storage.size) -}}
    {{- end }}
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    server: {{ $storage.server | default "" }}
    share: {{ $storage.share | default "" }}
    domain: {{ $storage.domain | default "" }}
    username: {{ $storage.username | default "" }}
    password: {{ $storage.password | default "" }}
    size: {{ $size }}
    {{- if eq $storage.type "smb-pv-pvc" }}
    mountOptions:
      - key: noperm
    {{- end }}
    targetSelector:
      planka:
        planka:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}


  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.plankaStorage.pgData
            "pgBackup" .Values.plankaStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
