{{- define "wordpress.cron" -}}
workload:
  wordpress-cron:
    enabled: true
    type: CronJob
    schedule: {{ .Values.wpConfig.cronSchedule | quote }}
    podSpec:
      hostNetwork: false
      restartPolicy: Never
      containers:
        wordpress-cron:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 33
            runAsGroup: 33
          command:
            - /usr/local/bin/php
          args:
            - /var/www/html/wp-cron.php
          envFrom:
            - secretRef:
                name: wordpress-creds
          {{ with .Values.wpConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: false
            readiness:
              enabled: false
            startup:
              enabled: false
{{- end -}}
