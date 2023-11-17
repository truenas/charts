{{- define "newsly.workload" -}}
workload:
  newsly:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.newslyNetwork.hostNetwork }}
      containers:
        newsly:
          enabled: true
          primary: true
          imageSelector: dbimage
          securityContext:
            runAsUser: {{ .Values.newslyRunAs.user }}
            runAsGroup: {{ .Values.newslyRunAs.group }}
          env:
            POSTGRES_DB : {{ .Values.newslyDatabase.host }}
            POSTGRES_USER : {{ .Values.newslyDatabase.username }}
            POSTGRES_PASSWORD : {{ .Values.newslyDatabase.password }}
          {{ with .Values.newslyConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              exec:
                command:
                  - sh
                  - -c
                  - "until pg_isready -U ${POSTGRES_USER} -h localhost; do sleep 2; done"
              initialDelaySeconds: 10
              periodSeconds: 10
              timeoutSeconds: 5
              failureThreshold: 5
              successThreshold: 1
            startup
              exec:
                command:
                  - sh
                  - -c
                  - "until pg_isready -U ${POSTGRES_USER} -h localhost; do sleep 2; done"
              initialDelaySeconds: 10
              periodSeconds: 5
              timeoutSeconds: 2
              failureThreshold: 60
              successThreshold: 1

{{/* Service */}}
service:
  newsly:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: newsly
    ports:
      postgres:
        enabled: true
        primary: true
        port: {{ .Values.newslyNetwork.webPort }}
        nodePort: {{ .Values.newslyNetwork.webPort }}
        targetSelector: newsly

persistance:

{{- end -}}
