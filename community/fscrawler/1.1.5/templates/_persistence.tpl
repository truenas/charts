{{- define "fscrawler.persistence" -}}
persistence:
  jobs:
    enabled: true
    type: {{ .Values.fscrawlerStorage.jobs.type }}
    datasetName: {{ .Values.fscrawlerStorage.jobs.datasetName | default "" }}
    hostPath: {{ .Values.fscrawlerStorage.jobs.hostPath | default "" }}
    targetSelector:
      fscrawler:
        fscrawler:
          mountPath: /root/.fscrawler
        config:
          mountPath: /root/.fscrawler
  default-config:
    enabled: true
    type: configmap
    objectName: example-config
    targetSelector:
      fscrawler:
        config:
          mountPath: /example/_settings.example.yaml
          subPath: _settings.example.yaml
  {{- range $idx, $storage := .Values.fscrawlerStorage.additionalStorages }}
  {{ printf "fscrawler-%v" (int $idx) }}:
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
      fscrawler:
        fscrawler:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
