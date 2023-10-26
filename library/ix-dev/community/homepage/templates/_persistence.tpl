{{- define "homepage.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.homepageStorage.config.type }}
    datasetName: {{ .Values.homepageStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.homepageStorage.config.hostPath | default "" }}
    targetSelector:
      homepage:
        homepage:
          mountPath: /app/config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      homepage:
        homepage:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.homepageStorage.additionalStorages }}
  {{ printf "homepage-%v" (int $idx) }}:
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
      homepage:
        homepage:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
