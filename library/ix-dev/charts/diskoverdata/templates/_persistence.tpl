{{- define "diskover.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.diskoverStorage.config) | nindent 4 }}
    targetSelector:
      diskover:
        diskover:
          mountPath: /config
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.diskoverStorage.data) | nindent 4 }}
    targetSelector:
      diskover:
        diskover:
          mountPath: /data
  esdata:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.diskoverStorage.esdata) | nindent 4 }}
    targetSelector:
      elasticsearch:
        elasticsearch:
          mountPath: /usr/share/elasticsearch/data

  phpfile:
    enabled: true
    type: configmap
    objectName: diskover-config
    targetSelector:
      diskover:
        diskover:
          mountPath: /config/diskover-web.conf.d/Constants.php
          subPath: Constants.php
  yamlfile:
    enabled: true
    type: configmap
    objectName: diskover-config
    targetSelector:
      diskover:
        diskover:
          mountPath: /config/diskover.conf.d/diskover/config.yaml
          subPath: config.yaml
  {{- range $idx, $storage := .Values.diskoverStorage.additionalStorages }}
  {{ printf "diskover-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      diskover:
        diskover:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
