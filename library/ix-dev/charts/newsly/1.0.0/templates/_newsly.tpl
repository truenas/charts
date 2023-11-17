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
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.newslyRunAs.user }}
            runAsGroup: {{ .Values.newslyRunAs.group }}
          env:
            FLASK_RUN_PORT: {{ .Values.newslyNetwork.webPort }}
            PYTHONUNBUFFERED : {{ .Values.newslyDatabase.pythonlogging }}
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
              path: /init-scraper
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
  newsly:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: newsly
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.newslyNetwork.webPort }}
        nodePort: {{ .Values.newslyNetwork.webPort }}
        targetSelector: newsly

{{- end -}}
