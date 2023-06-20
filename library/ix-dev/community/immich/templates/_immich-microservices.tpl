{{- define "immich.microservices.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $url := printf "http://%v-server:%v/server-info/ping" $fullname .Values.immichNetwork.serverPort }}
workload:
  microservices:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        microservices:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          args: start-microservices.sh
          envFrom:
            - secretRef:
                name: immich-creds
            - configMapRef:
                name: micro-config
          probes:
            liveness:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  ps -a | grep -v grep | grep -q microservices
            readiness:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  ps -a | grep -v grep | grep -q microservices
            startup:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  ps -a | grep -v grep | grep -q microservices
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.redisWait" (dict  "name" "redis-wait"
                                                      "secretName" "redis-creds") | nindent 8 }}
      {{- include "immich.wait.init" (dict "url" $url) | indent 8 }}
{{- end -}}
