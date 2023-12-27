{{- define "homer.workload" -}}
workload:
  homer:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.homerNetwork.hostNetwork }}
      containers:
        homer:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.homerRunAs.user }}
            runAsGroup: {{ .Values.homerRunAs.group }}
          env:
            PORT: {{ .Values.homerNetwork.webPort }}
            INIT_ASSETS: {{ ternary "1" "0" .Values.homerConfig.initAssets }}
          {{ with .Values.homerConfig.additionalEnvs }}
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
              port: {{ .Values.homerNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: http
              port: {{ .Values.homerNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: http
              port: {{ .Values.homerNetwork.webPort }}
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.homerRunAs.user
                                                        "GID" .Values.homerRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
