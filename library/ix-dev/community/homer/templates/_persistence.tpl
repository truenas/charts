{{- define "homer.persistence" -}}
persistence:
  assets:
    enabled: true
    type: {{ .Values.homerStorage.assets.type }}
    datasetName: {{ .Values.homerStorage.assets.datasetName | default "" }}
    hostPath: {{ .Values.homerStorage.assets.hostPath | default "" }}
    targetSelector:
      homer:
        homer:
          mountPath: /www/assets
        01-permissions:
          mountPath: /mnt/directories/assets
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      homer:
        homer:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.homerStorage.additionalStorages }}
  {{ printf "homer-%v" (int $idx) }}:
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
      homer:
        homer:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
