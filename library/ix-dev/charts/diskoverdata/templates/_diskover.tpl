{{- define "diskover.workload" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
  {{- $elasticsearch := printf "http://%s-elasticsearch:%v/_cluster/health?local=true" $fullname 9200 }}
workload:
  diskover:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      securityContext:
        fsGroup: {{ .Values.diskoverID.group }}
      containers:
        diskover:
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
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - SETGID
                - SETUID
                - KILL
          fixedEnv:
            PUID: {{ .Values.diskoverID.user }}
          {{ with .Values.diskoverConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              path: /login.php
              port: 80
            readiness:
              enabled: true
              type: http
              path: /login.php
              port: 80
            startup:
              enabled: true
              type: http
              path: /login.php
              port: 80
          lifecycle:
            {{- $sched := .Values.diskoverConfig.cronSchedule }}
            postStart:
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  /scripts/.default_crawler.sh /app/diskover/diskover.py /data;
                  {{- $cron := printf "%s python3 /app/diskover/diskover.py /data" $sched }}
                  if ! cat /config/crontab | grep -q "{{ $cron }}"; then
                    echo "{{ $cron }}" >> /config/crontab;
                  fi
                  {{- range $item := .Values.diskoverStorage.additionalStorages }}
                  /scripts/.default_crawler.sh /app/diskover/diskover.py {{ $item.mountPath }};
                  {{- end -}}
                  {{- range $item := .Values.diskoverStorage.additionalStorages }}
                    {{- if $item.diskoverDataIndex }}
                      {{- $cron := printf "%s python3 /app/diskover/diskover.py %s" $sched $item.mountPath }}
                      if ! cat /config/crontab | grep -q "{{ $cron }}"; then
                        echo "{{ $cron }}" >> /config/crontab;
                      fi
                    {{- end }}
                  {{- end }}
                  crontab /config/crontab;

      initContainers:
        01-wait-for-elasticsearch:
          enabled: true
          type: init
          imageSelector: bashImage
          env:
            ELASTIC_PASSWORD:
              secretKeyRef:
                name: diskover-secret
                key: es-password
          command:
            - bash
            - -c
          args:
            - |
              echo "Pinging [{{ $elasticsearch }}] until it is ready..."
              head="--header=Authorization: Basic x$(base64 <<< "elastic:$ELASTIC_PASSWORD")"
              time="--timeout=3"
              until wget "$head" "$time" --spider -qO- "{{ $elasticsearch }}"; do
                echo "Waiting for [{{ $elasticsearch }}] to be ready..."
                sleep 2
              done
              echo "URL [{{ $elasticsearch }}] is ready!"
{{- end -}}
