{{- define "metube.persistence" -}}
persistence:
  downloads:
    enabled: true
    type: {{ .Values.metubeStorage.downloads.type }}
    datasetName: {{ .Values.metubeStorage.downloads.datasetName | default "" }}
    hostPath: {{ .Values.metubeStorage.downloads.hostPath | default "" }}
    targetSelector:
      metube:
        metube:
          mountPath: /downloads
        01-permissions:
          mountPath: /mnt/directories/downloads
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      metube:
        metube:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.metubeStorage.additionalStorages }}
  {{ printf "metube-%v" (int $idx) }}:
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
      metube:
        metube:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
