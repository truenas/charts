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
      newsly:
        enabled: true
        primary: true
        port: 5432
        nodePort: {{ .Values.newslyDatabase.port }}
        targetSelector: newsly

{{/* Persistence */}}
persistence:
  dbdata:
    enabled: true
    type: {{ .Values.newslyStorage.config.type }}
    datasetName: {{ .Values.newslyStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.newslyStorage.config.hostPath | default "" }}
    targetSelector:
      newsly:
        newsly:
          mountPath: /var/lib/postgresql/data
        01-permissions:
          mountPath: /tmp
  dbrun:
    enabled: true
    type: {{ .Values.newslyStorage.config.type }}
    datasetName: {{ .Values.newslyStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.newslyStorage.config.hostPath | default "" }}
    targetSelector:
      newsly:
        newsly:
          mountPath: /var/run/postgresql

{{- end -}}