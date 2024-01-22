{{- define "fscrawler.persistence" -}}
persistence:
  jobs:
    enabled: true
    {{- include "fscrawler.storage.ci.migration" (dict "storage" .Values.fscrawlerStorage.jobs) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.fscrawlerStorage.jobs) | nindent 4 }}
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
  {{ printf "fscrawler-%v:" (int $idx) }}
    enabled: true
    {{- include "fscrawler.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      fscrawler:
        fscrawler:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "fscrawler.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
