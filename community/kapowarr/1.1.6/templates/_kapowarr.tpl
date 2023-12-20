{{- define "kapowarr.workload" -}}
workload:
  kapowarr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        kapowarr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.kapowarrRunAs.user }}
            runAsGroup: {{ .Values.kapowarrRunAs.group }}
          {{ with .Values.kapowarrConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: 5656
              path: /
            readiness:
              enabled: true
              type: http
              port: 5656
              path: /
            startup:
              enabled: true
              type: http
              port: 5656
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.kapowarrRunAs.user
                                                        "GID" .Values.kapowarrRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
{{- end -}}
