{{- define "nodered.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.noderedStorage.data.type }}
    datasetName: {{ .Values.noderedStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.noderedStorage.data.hostPath | default "" }}
    targetSelector:
      nodered:
        nodered:
          mountPath: /data
        01-permissions:
          mountPath: /mnt/directories/data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      nodered:
        nodered:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.noderedStorage.additionalStorages }}
  {{ printf "nodered-%v" (int $idx) }}:
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
      nodered:
        nodered:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
