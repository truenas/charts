{{- define "immich.micro.workload" -}}
workload:
  micro:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        micro:
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
      # TODO: Add init container to wait for redis
      # TODO: Add init container to wait for server
{{- end -}}
