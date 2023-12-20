{{- define "transmission.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.transmissionStorage.config.type }}
    datasetName: {{ .Values.transmissionStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.transmissionStorage.config.hostPath | default "" }}
    targetSelector:
      transmission:
        transmission:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  download-complete:
    enabled: true
    type: {{ .Values.transmissionStorage.downloadsComplete.type }}
    datasetName: {{ .Values.transmissionStorage.downloadsComplete.datasetName | default "" }}
    hostPath: {{ .Values.transmissionStorage.downloadsComplete.hostPath | default "" }}
    targetSelector:
      transmission:
        transmission:
          mountPath: {{ .Values.transmissionStorage.downloadsDir | default "/downloads/complete" }}
        01-permissions:
          mountPath: /mnt/directories/complete
  {{- if .Values.transmissionStorage.enableIncompleteDir }}
  download-incomplete:
    enabled: true
    type: {{ .Values.transmissionStorage.downloadsIncomplete.type }}
    datasetName: {{ .Values.transmissionStorage.downloadsIncomplete.datasetName | default "" }}
    hostPath: {{ .Values.transmissionStorage.downloadsIncomplete.hostPath | default "" }}
    targetSelector:
      transmission:
        transmission:
          mountPath: {{ .Values.transmissionStorage.incompleteDir | default "/downloads/incomplete" }}
        01-permissions:
          mountPath: /mnt/directories/incomplete
  {{- end -}}
  {{- range $idx, $storage := .Values.transmissionStorage.additionalStorages }}
  {{ printf "transmission-%v" (int $idx) }}:
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
      transmission:
        transmission:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
