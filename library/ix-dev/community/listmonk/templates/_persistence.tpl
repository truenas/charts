{{- define "listmonk.persistence" -}}
persistence:
  uploads:
    enabled: true
    type: {{ .Values.listmonkStorage.uploads.type }}
    datasetName: {{ .Values.listmonkStorage.uploads.datasetName | default "" }}
    hostPath: {{ .Values.listmonkStorage.uploads.hostPath | default "" }}
    targetSelector:
      listmonk:
        listmonk:
          mountPath: /listmonk/uploads
        01-permissions:
          mountPath: /mnt/directories/uploads
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      listmonk:
        listmonk:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.listmonkStorage.additionalStorages }}
  {{ printf "listmonk-%v" (int $idx) }}:
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
      listmonk:
        listmonk:
          mountPath: {{ $storage.mountPath }}
  {{- end -}}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.listmonkStorage.pgData
            "pgBackup" .Values.listmonkStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
