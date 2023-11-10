{{- define "freshrss.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.freshrssStorage.data.type }}
    datasetName: {{ .Values.freshrssStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.freshrssStorage.data.hostPath | default "" }}
    targetSelector:
      freshrss:
        freshrss:
          mountPath: /var/www/FreshRSS/data
      freshrss-cron:
        freshrss-cron:
          mountPath: /var/www/FreshRSS/data
  extensions:
    enabled: true
    type: {{ .Values.freshrssStorage.extensions.type }}
    datasetName: {{ .Values.freshrssStorage.extensions.datasetName | default "" }}
    hostPath: {{ .Values.freshrssStorage.extensions.hostPath | default "" }}
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
  {{ printf "freshrss-%v" (int $idx) }}:
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
