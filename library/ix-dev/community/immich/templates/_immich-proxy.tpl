{{- define "immich.proxy.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $serverUrl := printf "http://%v-server:%v/server-info/ping" $fullname .Values.immichNetwork.serverPort -}}
{{- $webUrl := printf "http://%v-web:%v/robots.txt" $fullname .Values.immichNetwork.webPort }}
workload:
  proxy:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        proxy:
          enabled: true
          primary: true
          imageSelector: proxyImage
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - SETUID
                - SETGID
          envFrom:
            - configMapRef:
                name: proxy-config
          probes:
            liveness:
              enabled: true
              type: http
              path: /api/server-info/ping
              port: 8080
            readiness:
              enabled: true
              type: http
              path: /api/server-info/ping
              port: 8080
            startup:
              enabled: true
              type: http
              path: /api/server-info/ping
              port: 8080
      initContainers:
      {{- include "immich.wait.init" (dict "url" $serverUrl) | indent 8 }}
      {{- include "immich.wait.init" (dict "url" $webUrl) | indent 8 }}
{{- end -}}
