{{- define "recyclarr.workload" -}}
workload:
  recyclarr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        recyclarr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.recyclarrRunAs.user }}
            runAsGroup: {{ .Values.recyclarrRunAs.group }}
          env:
            RECYCLARR_APP_DATA: /config
            RECYCLARR_CREATE_CONFIG: {{ .Values.recyclarrConfig.createConfig }}
            CRON_SCHEDULE: {{ .Values.recyclarrConfig.cronSchedule | quote}}
          {{ with .Values.recyclarrConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            # Nothing to probe
            liveness:
              enabled: false
            readiness:
              enabled: false
            startup:
              enabled: false
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.recyclarrRunAs.user
                                                        "GID" .Values.recyclarrRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
