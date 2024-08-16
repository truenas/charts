{{- define "vikunja.nginx" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $frontUrl := printf "http://%v-frontend:%v/ready" $fullname .Values.vikunjaPorts.frontHttp }}
workload:
  vikunja-proxy:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        vikunja-proxy:
          enabled: true
          primary: true
          imageSelector: nginxImage
          securityContext:
            runAsUser: 101
            runAsGroup: 101
          probes:
            liveness:
              enabled: true
              type: http
              port: {{ .Values.vikunjaNetwork.webPort }}
              path: /nginx-health
            readiness:
              enabled: true
              type: http
              port: {{ .Values.vikunjaNetwork.webPort }}
              path: /nginx-health
            startup:
              enabled: true
              type: http
              port: {{ .Values.vikunjaNetwork.webPort }}
              path: /nginx-health
      initContainers:
      {{- include "vikunja.wait.init" (dict "url" $frontUrl) | indent 8 }}
{{- end -}}
