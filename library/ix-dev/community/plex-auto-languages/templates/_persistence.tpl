{{- define "pal.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.palStorage.config.type }}
    datasetName: {{ .Values.palStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.palStorage.config.hostPath | default "" }}
    targetSelector:
      pal:
        pal:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      pal:
        pal:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.palStorage.additionalStorages }}
  {{ printf "pal-%v" (int $idx) }}:
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
      pal:
        pal:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
