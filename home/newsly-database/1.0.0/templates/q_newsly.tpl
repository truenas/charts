{{- define "newsly.workload" -}}
workload:
  newsly-db:
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
            POSTGRES_USER : {{ .Values.newslyDatabase.username }}
            POSTGRES_PASSWORD : {{ .Values.newslyDatabase.password }}
            POSTGRES_DB : {{ .Values.newslyDatabase.dbname }}
          {{ with .Values.newslyConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: false
              type: http
              port: "{{ .Values.newslyNetwork.webPort }}"
              path: /
              initialDelaySeconds: 5
              periodSeconds: 60
            readiness:
              enabled: false
              type: http
              port: "{{ .Values.newslyNetwork.webPort }}"
              path: /
            startup:
              enabled: false
              type: http
              port: "{{ .Values.newslyNetwork.webPort }}"
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.newslyRunAs.user
                                                        "GID" .Values.newslyRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
{{/* Service */}}
service:
  newsly-db:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: newsly-db
    ports:
      webui:
        enabled: true
        primary: true
        port: 5432
        nodePort: {{ .Values.newslyDatabase.port }}
        targetSelector: newsly-db

{{- end -}}
