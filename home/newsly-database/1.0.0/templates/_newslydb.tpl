{{- define "newslydb.workload" -}}
workload:
  newslydb:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.newslydbNetwork.hostNetwork }}
      containers:
        newslydb:
          enabled: true
          primary: true
          imageSelector: dbimage
          securityContext:
            runAsUser: {{ .Values.newslydbRunAs.user }}
            runAsGroup: {{ .Values.newslydbRunAs.group }}
          env:
            POSTGRES_USER : {{ .Values.newslydbDatabase.username }}
            POSTGRES_PASSWORD : {{ .Values.newslydbDatabase.password }}
          {{ with .Values.newslydbConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: false
            readiness:
              enabled: false
            startup:
              enabled: false

{{/* Service */}}
service:
  newslydb:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: newslydb
    ports:
      newslydb:
        enabled: true
        primary: true
        port: 5432
        nodePort: {{ .Values.newslydbDatabase.port }}
        targetSelector: newslydb



{{- end -}}
