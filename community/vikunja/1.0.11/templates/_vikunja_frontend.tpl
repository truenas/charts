{{- define "vikunja.frontend" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $apiUrl := printf "http://%v:%v/health" $fullname .Values.vikunjaPorts.api }}
workload:
  vikunja-frontend:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        vikunja-frontend:
          enabled: true
          primary: true
          imageSelector: frontendImage
          securityContext:
            runAsUser: 101
            runAsGroup: 101
            readOnlyRootFilesystem: false
          envFrom:
            - configMapRef:
                name: vikunja-frontend
          probes:
            liveness:
              enabled: true
              type: http
              port: {{ .Values.vikunjaPorts.frontHttp }}
              path: /ready
            readiness:
              enabled: true
              type: http
              port: {{ .Values.vikunjaPorts.frontHttp }}
              path: /ready
            startup:
              enabled: true
              type: http
              port: {{ .Values.vikunjaPorts.frontHttp }}
              path: /ready
      initContainers:
      {{- include "vikunja.wait.init" (dict "url" $apiUrl) | indent 8 }}
{{- end -}}
