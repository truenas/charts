{{- define "storj.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.storjStorage.data) | nindent 4 }}
    targetSelector:
      storj:
        storj:
          mountPath: /app/config
        {{- if and (eq .Values.storjStorage.data.type "ixVolume")
                  (not (.Values.storjStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
        03-setup:
          mountPath: /app/config
  identity:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.storjStorage.identity) | nindent 4 }}
    targetSelector:
      storj:
        storj:
          mountPath: /app/identity
        {{- if and (eq .Values.storjStorage.identity.type "ixVolume")
                  (not (.Values.storjStorage.identity.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/identity
        {{- end }}
        02-generateid:
          mountPath: {{ template "storj.idPath" }}
        03-setup:
          mountPath: /app/identity
  initscript:
    enabled: true
    type: configmap
    objectName: storj
    defaultMode: "0755"
    targetSelector:
      storj:
        02-generateid:
          mountPath: /init_script/init_config.sh
          subPath: init_config.sh
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      storj:
        storj:
          mountPath: /tmp
        02-generateid:
          mountPath: /tmp
        03-setup:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.storjStorage.additionalStorages }}
  {{ printf "storj-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      storj:
        storj:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
