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
  {{ printf "briefkasten-%v" (int $idx) }}:
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
      briefkasten:
        briefkasten:
          mountPath: {{ $storage.mountPath }}
  {{- end -}}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.briefkastenStorage.pgData
            "pgBackup" .Values.briefkastenStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
