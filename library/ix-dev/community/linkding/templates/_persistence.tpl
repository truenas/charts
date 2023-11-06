{{- define "linkding.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.linkdingStorage.data.type }}
    datasetName: {{ .Values.linkdingStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.linkdingStorage.data.hostPath | default "" }}
    targetSelector:
      linkding:
        linkding:
          mountPath: /etc/linkding/data
        01-permissions:
          mountPath: /mnt/directories/data
  secret:
    enabled: true
    type: secret
    objectName: linkding-secret
    defaultMode: "0600"
    targetSelector:
      linkding:
        linkding:
          mountPath: /etc/linkding/secretkey.txt
          subPath: secretkey.txt
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      linkding:
        linkding:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.linkdingStorage.additionalStorages }}
  {{ printf "linkding-%v" (int $idx) }}:
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
      linkding:
        linkding:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.linkdingStorage.pgData
            "pgBackup" .Values.linkdingStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
