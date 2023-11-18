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
              type: http
              port: "{{ .Values.newslydbNetwork.webPort }}"
              path: /
              initialDelaySeconds: 5
              periodSeconds: 60
            readiness:
              enabled: false
              type: http
              port: "{{ .Values.newslydbNetwork.webPort }}"
              path: /
            startup:
              enabled: false
              type: http
              port: "{{ .Values.newslydbNetwork.webPort }}"
              path: /

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

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    type: {{ .Values.newslydbStorage.config.type }}
    datasetName: {{ .Values.newslydbStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.newslydbStorage.config.hostPath | default "" }}
    targetSelector:
      newslydb:
        newslydb:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config

{{- end -}}
