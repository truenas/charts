{{- define "odoo.workload" -}}
workload:
  odoo:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.odooNetwork.hostNetwork }}
      containers:
        odoo:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.odooRunAs.user }}
            runAsGroup: {{ .Values.odooRunAs.group }}
          env:
            ODOO_RC: /etc/odoo/odoo.conf
          {{ with .Values.odooConfig.additionalEnvs }}
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
              path: /web/health
              port: {{ .Values.odooNetwork.webPort }}
            readiness:
              enabled: true
              type: http
              path: /web/health
              port: {{ .Values.odooNetwork.webPort }}
            startup:
              enabled: true
              type: http
              path: /web/health
              port: {{ .Values.odooNetwork.webPort }}
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.odooRunAs.user
                                                        "GID" .Values.odooRunAs.group
                                                        "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{- end -}}
