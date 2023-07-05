{{/* Returns a redis pod with init container for fixing permissions
and a pre-upgrade job to backup the database */}}
{{/* Call this template:
{{ include "ix.v1.common.app.redis" (dict "name" "redis" "secretName" "redis-creds" "resources" .Values.resources) }}

name (optional): Name of the redis pod/container (default: redis)
secretName (required): Name of the secret containing the redis credentials
resources (required): Resources for the redis container
*/}}
{{- define "ix.v1.common.app.redis" -}}
  {{- $name := .name | default "redis" -}}
  {{- $secretName := (required "Redis - Secret Name is required" .secretName) -}}
  {{- $resources := (required "Redis - Resources are required" .resources) }}
{{ $name }}:
  enabled: true
  type: Deployment
  podSpec:
    securityContext:
      fsGroup: 1001
    containers:
      {{ $name }}:
        enabled: true
        primary: true
        imageSelector: redisImage
        securityContext:
          runAsUser: 1001
          runAsGroup: 0
          runAsNonRoot: false
          readOnlyRootFilesystem: false
        resources:
          limits:
            cpu: {{ $resources.limits.cpu }}
            memory: {{ $resources.limits.memory }}
        envFrom:
          - secretRef:
              name: {{ $secretName }}
        probes:
          liveness:
            enabled: true
            type: exec
            command:
              - /bin/sh
              - -c
              - redis-cli -a "$REDIS_PASSWORD" -p ${REDIS_PORT_NUMBER:-6379} ping | grep -q PONG
          readiness:
            enabled: true
            type: exec
            command:
              - /bin/sh
              - -c
              - redis-cli -a "$REDIS_PASSWORD" -p ${REDIS_PORT_NUMBER:-6379} ping | grep -q PONG
          startup:
            enabled: true
            type: exec
            command:
              - /bin/sh
              - -c
              - redis-cli -a "$REDIS_PASSWORD" -p ${REDIS_PORT_NUMBER:-6379} ping | grep -q PONG
{{- end -}}

{{/* Returns a redis-wait container for waiting for redis to be ready */}}
{{/* Call this template:
{{ include "ix.v1.common.app.redisWait" (dict "name" "redis-wait" "secretName" "redis-creds") }}

name (optional): Name of the redis-wait container (default: redis-wait)
secretName (required): Name of the secret containing the redis credentials
*/}}

{{- define "ix.v1.common.app.redisWait" -}}
  {{- $name := .name | default "redis-wait" -}}
  {{- $secretName := (required "Redis-Wait - Secret Name is required" .secretName) }}
{{ $name }}:
  enabled: true
  type: init
  imageSelector: redisImage
  envFrom:
    - secretRef:
        name: {{ $secretName }}
  resources:
    limits:
      cpu: 500m
      memory: 256Mi
  command: bash
  args:
    - -c
    - |
      echo "Waiting for redis to be ready"
      until redis-cli -h "$REDIS_HOST" -a "$REDIS_PASSWORD" -p ${REDIS_PORT_NUMBER:-6379} ping | grep -q PONG; do
        echo "Waiting for redis to be ready. Sleeping 2 seconds..."
        sleep 2
      done
      echo "Redis is ready!"
{{- end -}}
