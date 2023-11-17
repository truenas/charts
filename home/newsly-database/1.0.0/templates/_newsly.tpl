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
