{{- define "navidrome.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.navidromeStorage.data.type }}
    datasetName: {{ .Values.navidromeStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.navidromeStorage.data.hostPath | default "" }}
    targetSelector:
      navidrome:
        navidrome:
          mountPath: /data
        01-permissions:
          mountPath: /mnt/directories/data
  music:
    enabled: true
    type: {{ .Values.navidromeStorage.music.type }}
    datasetName: {{ .Values.navidromeStorage.music.datasetName | default "" }}
    hostPath: {{ .Values.navidromeStorage.music.hostPath | default "" }}
    targetSelector:
      navidrome:
        navidrome:
          mountPath: /music
        01-permissions:
          mountPath: /mnt/directories/music
  {{- range $idx, $storage := .Values.navidromeStorage.additionalStorages }}
  {{ printf "navidrome-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      navidrome:
        navidrome:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
