{{- define "immich.proxy.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $url := printf "http://%v-server:%v/server-info/ping" $fullname .Values.immichNetwork.serverPort }}
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
      {{- include "immich.wait.init" (dict "url" $url) | indent 8 }}
{{- end -}}
