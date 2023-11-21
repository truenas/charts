{{- define "freshrss.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.freshrssStorage.data) | nindent 4 }}
    targetSelector:
      freshrss:
        freshrss:
          mountPath: /var/www/FreshRSS/data
      freshrss-cron:
        freshrss-cron:
          mountPath: /var/www/FreshRSS/data
  extensions:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.freshrssStorage.extensions) | nindent 4 }}
    targetSelector:
      freshrss:
        freshrss:
          mountPath: /var/www/FreshRSS/extensions
      freshrss:
        freshrss:
          mountPath: /var/www/FreshRSS/extensions
      freshrss-cron:
        freshrss-cron:
          mountPath: /var/www/FreshRSS/extensions
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      freshrss:
        freshrss:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.freshrssStorage.additionalStorages }}
  {{ printf "freshrss-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      freshrss:
        freshrss:
          mountPath: {{ $storage.mountPath }}
      freshrss-cron:
        freshrss-cron:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.freshrssStorage.pgData
            "pgBackup" .Values.freshrssStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
