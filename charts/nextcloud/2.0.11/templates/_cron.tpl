{{- define "nextcloud.cron" -}}
workload:
  nextcloud-cron:
    enabled: true
    type: CronJob
    schedule: {{ .Values.ncConfig.cron.schedule | quote }}
    concurrencyPolicy: Forbid
    podSpec:
      restartPolicy: Never
      hostNetwork: false
      securityContext:
        fsGroup: 33
      containers:
        nextcloud-cron:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 33
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          envFrom:
            - secretRef:
                name: nextcloud-creds
          command:
            - php
            - -f
            - /var/www/html/cron.php
          probes:
            liveness:
              enabled: false
            readiness:
              enabled: false
            startup:
              enabled: false
{{- end -}}
