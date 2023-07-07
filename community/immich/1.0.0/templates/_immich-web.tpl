{{- define "immich.web.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $url := printf "http://%v-server:%v/server-info/ping" $fullname .Values.immichNetwork.serverPort }}
workload:
  web:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        web:
          enabled: true
          primary: true
          imageSelector: webImage
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - SETUID
                - SETGID
          envFrom:
            - configMapRef:
                name: web-config
          probes:
            liveness:
              enabled: true
              type: http
              path: /robots.txt
              port: {{ .Values.immichNetwork.webPort }}
            readiness:
              enabled: true
              type: http
              path: /robots.txt
              port: {{ .Values.immichNetwork.webPort }}
            startup:
              enabled: true
              type: http
              path: /robots.txt
              port: {{ .Values.immichNetwork.webPort }}
      initContainers:
      {{- include "immich.wait.init" (dict "url" $url) | indent 8 }}
{{- end -}}
