{{- define "tmm.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.tmmStorage.data.type }}
    datasetName: {{ .Values.tmmStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.tmmStorage.data.hostPath | default "" }}
    targetSelector:
      tmm:
        tmm:
          mountPath: /data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      tmm:
        tmm:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.tmmStorage.additionalStorages }}
  {{ printf "tmm-%v" (int $idx) }}:
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
      tmm:
        tmm:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
