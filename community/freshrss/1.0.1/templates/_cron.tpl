{{- define "freshrss.cron" -}}
workload:
  freshrss-cron:
    enabled: true
    type: CronJob
    schedule: {{ .Values.freshrssConfig.cronSchedule | quote }}
    podSpec:
      hostNetwork: {{ .Values.freshrssNetwork.hostNetwork }}
      restartPolicy: Never
      containers:
        freshrss-cron:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - SETGID
                - SETUID
          command:
            - /bin/sh
          args:
            - -c
            - |
              /var/www/FreshRSS/app/actualize_script.php
          envFrom:
            - secretRef:
                name: freshrss-creds
            - configMapRef:
                name: freshrss-config
          {{ with .Values.freshrssConfig.additionalEnvs }}
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
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "01-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
