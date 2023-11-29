{{- define "komga.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.komgaStorage.config.type }}
    datasetName: {{ .Values.komgaStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.komgaStorage.config.hostPath | default "" }}
    targetSelector:
      komga:
        komga:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      komga:
        komga:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.komgaStorage.additionalStorages }}
  {{ printf "komga-%v" (int $idx) }}:
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
      komga:
        komga:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
