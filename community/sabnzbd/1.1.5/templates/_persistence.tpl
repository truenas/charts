{{- define "sabnzbd.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.sabnzbdStorage.config.type }}
    datasetName: {{ .Values.sabnzbdStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.sabnzbdStorage.config.hostPath | default "" }}
    targetSelector:
      sabnzbd:
        sabnzbd:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      sabnzbd:
        sabnzbd:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.sabnzbdStorage.additionalStorages }}
  {{ printf "sabnzbd-%v" (int $idx) }}:
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
      sabnzbd:
        sabnzbd:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
