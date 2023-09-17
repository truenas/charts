{{- define "firefly.cron" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) }}
workload:
  firefly-cron:
    enabled: true
    type: CronJob
    schedule: "0 3 * * *"
    podSpec:
      restartPolicy: Never
      backoffLimit: 2
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
            - bash
          args:
            - -c
            - |
              until wget --spider --quiet --timeout=3 --tries=1 \
                {{ $fullname }}:{{ .Values.fireflyNetwork.webPort }}/health; do
                echo "Waiting for Firefly to start..."
                sleep 2
              done
              if wget --spider --quiet --timeout=3 --tries=1 \
                {{ $fullname }}:{{ .Values.fireflyNetwork.webPort }}/api/v1/cron/$(CRON_TOKEN);
              then
                echo "Cron job successfully executed"
              else
                echo "Cron job failed"
                exit 1
              fi
{{- end -}}
