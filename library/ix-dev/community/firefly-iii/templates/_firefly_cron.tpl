{{- define "firefly.cron" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) }}
workload:
  firefly-cron:
    enabled: true
    type: CronJob
    schedule: "0 3 * * *"
    podSpec:
      restartPolicy: Never
      containers:
        firefly-cron:
          enabled: true
          primary: true
          imageSelector: bashImage
          env:
            CRON_TOKEN:
              secretKeyRef:
                name: firefly-config
                key: STATIC_CRON_TOKEN
          probes:
            startup:
              enabled: false
            readiness:
              enabled: false
            liveness:
              enabled: false
          command:
            - /bin/bash
          args:
            - -c
            - |
              curl {{ $fullname }}:{{ .Values.fireflyNetwork.webPort }}/api/v1/cron/$(CRON_TOKEN)
{{- end -}}
