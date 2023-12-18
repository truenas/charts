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
            runAsUser: 101
            runAsGroup: 101
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
                                                    "UID" 101
                                                    "GID" 101
                                                    "mode" "check"
                                                    "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "02-postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
        {{- if .Release.IsInstall }} {{/* If we use type: install it will run before the postgres wait and fail */}}
        02-db-init:
          enabled: true
          type: init
          imageSelector: image
          securityContext:
            runAsUser: 101
            runAsGroup: 101
          env:
            ODOO_RC: /etc/odoo/odoo.conf
          command:
            - /bin/bash
            - -c
            - |
              /usr/bin/odoo --config=/etc/odoo/odoo.conf \
                            --stop-after-init \
                            --without-demo=all \
                            --init=base
        {{- end -}}
{{- end -}}
