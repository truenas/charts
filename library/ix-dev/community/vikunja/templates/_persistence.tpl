{{- define "vikunja.persistence" -}}
persistence:
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      vikunja:
        vikunja:
          mountPath: /tmp
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.vikunjaStorage.data) | nindent 4 }}
    targetSelector:
      vikunja-api:
        vikunja-api:
          mountPath: /app/vikunja/files
  nginx:
    enabled: true
    type: configmap
    objectName: nginx-config
    defaultMode: "0600"
    targetSelector:
      vikunja:
        vikunja:
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
  {{- end -}}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.vikunjaStorage.pgData
            "pgBackup" .Values.vikunjaStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
