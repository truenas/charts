{{- define "recyclarr.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.recyclarrStorage.config.type }}
    datasetName: {{ .Values.recyclarrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.recyclarrStorage.config.hostPath | default "" }}
    targetSelector:
      recyclarr:
        recyclarr:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      recyclarr:
        recyclarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.recyclarrStorage.additionalStorages }}
  {{ printf "recyclarr-%v" (int $idx) }}:
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
      recyclarr:
        recyclarr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
