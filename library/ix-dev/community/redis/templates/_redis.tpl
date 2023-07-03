{{- define "redis.workload" -}}
workload:
  redis:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.redisNetwork.hostNetwork }}
      securityContext:
        fsGroup: 1001
      containers:
        redis:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 1001
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          envFrom:
            - configMapRef:
                name: config
          {{ with .Values.redisConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            {{ $args := printf "-p %v" .Values.redisNetwork.redisPort }}
            {{ if not .Values.redisConfig.allowEmptyPassword }}
              {{ $args = printf "%v -a %v" $args .Values.redisConfig.password }}
            {{ end }}
            liveness:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  redis-cli {{ $args }} ping | grep -q PONG
            readiness:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  redis-cli {{ $args }} ping | grep -q PONG
            startup:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  redis-cli {{ $args }} ping | grep -q PONG
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 1001
                                                        "GID" 1001
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
{{/* Service */}}
service:
  redis:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: redis
    ports:
      redis:
        enabled: true
        primary: true
        port: {{ .Values.redisNetwork.redisPort }}
        nodePort: {{ .Values.redisNetwork.redisPort }}
        targetSelector: redis

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    type: {{ .Values.redisStorage.data.type }}
    datasetName: {{ .Values.redisStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.redisStorage.data.hostPath | default "" }}
    targetSelector:
      redis:
        redis:
          mountPath: /bitnami/redis/data
        01-permissions:
          mountPath: /mnt/directories/data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      redis:
        redis:
          mountPath: /tmp
{{- end -}}
