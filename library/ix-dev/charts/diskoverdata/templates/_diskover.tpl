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
      initContainers:
        01-wait-for-elasticsearch:
          enabled: true
          type: init
          imageSelector: bashImage
          command:
            - /bin/sh
            - -c
          args:
            - |
              echo "Pinging [{{ $elasticsearch }}] until it is ready..."
              header='--header=Authorization: Basic {{ printf "elastic:%s" "changeme" | b64enc }}'
              until wget "$header" --spider --quiet "{{ $elasticsearch }}"; do
                echo "Waiting for [{{ $elasticsearch }}] to be ready..."
                sleep 2
              done
              echo "URL [{{ $elasticsearch }}] is ready!"
        # 02-init-config:
        #   enabled: true
        #   type: init
{{- end -}}
