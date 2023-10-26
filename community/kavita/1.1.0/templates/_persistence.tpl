{{- define "kavita.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.kavitaStorage.config.type }}
    datasetName: {{ .Values.kavitaStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.kavitaStorage.config.hostPath | default "" }}
    targetSelector:
      kavita:
        kavita:
          mountPath: /kavita/config

  {{- range $idx, $storage := .Values.kavitaStorage.additionalStorages }}
  {{ printf "kavita-%v" (int $idx) }}:
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
      kavita:
        kavita:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
