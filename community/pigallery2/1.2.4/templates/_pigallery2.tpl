{{- define "pigallery.workload" -}}
workload:
  pigallery:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.pigalleryNetwork.hostNetwork }}
      containers:
        pigallery:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.pigalleryRunAs.user }}
            runAsGroup: {{ .Values.pigalleryRunAs.group }}
          envFrom:
            - configMapRef:
                name: pigallery-config
          {{ with .Values.pigalleryConfig.additionalEnvs }}
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
              port: {{ .Values.pigalleryNetwork.webPort }}
              path: /heartbeat
            readiness:
              enabled: true
              type: http
              port: {{ .Values.pigalleryNetwork.webPort }}
              path: /heartbeat
            startup:
              enabled: true
              type: http
              port: {{ .Values.pigalleryNetwork.webPort }}
              path: /heartbeat
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.pigalleryRunAs.user
                                                        "GID" .Values.pigalleryRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
