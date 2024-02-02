{{- define "invidious.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.invidiousStorage.config) | nindent 4 }}
    targetSelector:
      invidious:
        invidious:
          mountPath: /config
        04-init-config:
          mountPath: /config
        05-update-config:
          mountPath: /config
        {{- if and (eq .Values.invidiousStorage.config.type "ixVolume")
                  (not (.Values.invidiousStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  shared:
    enabled: true
    type: emptyDir
    targetSelector:
      invidious:
        02-fetch-seed:
          mountPath: /shared
        03-init-db:
          mountPath: /shared
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      invidious:
        invidious:
          mountPath: /tmp
  config-script:
    enabled: true
    type: secret
    objectName: invidious-creds
    defaultMode: "0550"
    targetSelector:
      invidious:
        05-update-config:
          mountPath: /setup/config.sh
          subPath: config.sh

  {{- range $idx, $storage := .Values.invidiousStorage.additionalStorages }}
  {{ printf "invidious-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      invidious:
        invidious:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.invidiousStorage.pgData
            "pgBackup" .Values.invidiousStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
