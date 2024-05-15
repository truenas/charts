{{- define "immich.microservices.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $url := printf "http://%v:%v/api/server-info/ping" $fullname .Values.immichNetwork.webuiPort }}
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
          command: /bin/sh
          args:
            - -c
            - /usr/src/app/start-microservices.sh
          envFrom:
            - secretRef:
                name: immich-creds
            - configMapRef:
                name: micro-config
          probes:
            liveness:
              enabled: true
              type: tcp
              port: {{ .Values.immichNetwork.microservicesPort }}
            readiness:
              enabled: true
              type: tcp
              port: {{ .Values.immichNetwork.microservicesPort }}
            startup:
              enabled: true
              type: tcp
              port: {{ .Values.immichNetwork.microservicesPort }}
      initContainers:
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
      {{- include "ix.v1.common.app.redisWait" (dict  "name" "redis-wait"
                                                      "secretName" "redis-creds") | nindent 8 }}
      {{- include "immich.wait.init" (dict "url" $url) | indent 8 }}
{{- end -}}
