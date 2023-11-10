{{- define "paperless.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.paperlessStorage.data.type }}
    datasetName: {{ .Values.paperlessStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.paperlessStorage.data.hostPath | default "" }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/data
  media:
    enabled: true
    type: {{ .Values.paperlessStorage.media.type }}
    datasetName: {{ .Values.paperlessStorage.media.datasetName | default "" }}
    hostPath: {{ .Values.paperlessStorage.media.hostPath | default "" }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/media
  consume:
    enabled: true
    type: {{ .Values.paperlessStorage.consume.type }}
    datasetName: {{ .Values.paperlessStorage.consume.datasetName | default "" }}
    hostPath: {{ .Values.paperlessStorage.consume.hostPath | default "" }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/consume
  trash:
    enabled: true
    type: {{ .Values.paperlessStorage.trash.type }}
    datasetName: {{ .Values.paperlessStorage.trash.datasetName | default "" }}
    hostPath: {{ .Values.paperlessStorage.trash.hostPath | default "" }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/trash
        01-permissions:
          mountPath: /mnt/directories/trash
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      paperless:
        paperless:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.paperlessStorage.additionalStorages }}
  {{ printf "paperless-%v" (int $idx) }}:
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
      paperless:
        paperless:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.paperlessStorage.pgData
            "pgBackup" .Values.paperlessStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
