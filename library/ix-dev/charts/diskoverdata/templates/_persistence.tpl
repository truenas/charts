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
        {{- if and (eq .Values.diskoverStorage.esdata.type "ixVolume")
                  (not (.Values.diskoverStorage.esdata.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/esdata
        {{- end }}
  defaultcrawler:
    enabled: true
    type: configmap
    objectName: diskover-config
    defaultMode: "0755"
    targetSelector:
      diskover:
        diskover:
          mountPath: /scripts/default_crawler.sh
          subPath: .default_crawler.sh
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
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      diskover:
        01-wait-for-elasticsearch:
          mountPath: /tmp
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
