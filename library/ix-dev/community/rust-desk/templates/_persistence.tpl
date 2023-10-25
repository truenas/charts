{{- define "rust.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.rustStorage.data.type }}
    datasetName: {{ .Values.rustStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.rustStorage.data.hostPath | default "" }}
    targetSelector:
      server:
        server:
          mountPath: /root
        01-permissions:
          mountPath: /mnt/directories/data
      relay:
        relay:
          mountPath: /root
  {{- range $idx, $storage := .Values.rustStorage.additionalStorages }}
  {{ printf "rust-%v" (int $idx) }}:
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
      server:
        server:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
      relay:
        relay:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
