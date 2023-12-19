{{- define "vikunja.persistence" -}}
persistence:
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      vikunja:
        vikunja:
          mountPath: /tmp
  nginxvar:
    enabled: true
    type: emptyDir
    targetSelector:
      vikunja-proxy:
        vikunja-proxy:
          mountPath: /var/cache/nginx
  nginxrun:
    enabled: true
    type: emptyDir
    targetSelector:
      vikunja-proxy:
        vikunja-proxy:
          mountPath: /var/run
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.vikunjaStorage.data) | nindent 4 }}
    targetSelector:
      vikunja-api:
        vikunja-api:
          mountPath: /app/vikunja/files
        {{- if and (eq .Values.vikunjaStorage.data.type "ixVolume")
                  (not (.Values.vikunjaStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  nginx:
    enabled: true
    type: configmap
    objectName: nginx-config
    defaultMode: "0600"
    targetSelector:
      vikunja-proxy:
        vikunja-proxy:
          mountPath: /etc/nginx/conf.d/default.conf
          subPath: nginx-config
          readOnly: true

  {{- range $idx, $storage := .Values.vikunjaStorage.additionalStorages }}
  {{ printf "vikunja-%v" (int $idx) }}:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      vikunja-api:
        vikunja-api:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end -}}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.vikunjaStorage.pgData
            "pgBackup" .Values.vikunjaStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
