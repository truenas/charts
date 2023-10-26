{{- define "prowlarr.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.prowlarrStorage.config.type }}
    datasetName: {{ .Values.prowlarrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.prowlarrStorage.config.hostPath | default "" }}
    targetSelector:
      prowlarr:
        prowlarr:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      prowlarr:
        prowlarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.prowlarrStorage.additionalStorages }}
  {{ printf "prowlarr-%v" (int $idx) }}:
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
      prowlarr:
        prowlarr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
