{{- define "pihole.workload" -}}
workload:
  pihole:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: true
      containers:
        pihole:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            allowPrivilegeEscalation: true
            capabilities:
              add:
                - NET_ADMIN
                - NET_RAW
                - NET_BIND_SERVICE
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - SETGID
                - SETUID
                - SETFCAP
                - SETPCAP
                - KILL
          env:
            WEB_PORT: {{ .Values.piholeNetwork.webPort }}
            WEBPASSWORD: {{ .Values.piholeConfig.webPassword | quote }}
            {{- if .Values.piholeNetwork.dhcp.enabled }}
            DHCP_ACTIVE: "true"
            DHCP_START: {{ .Values.piholeNetwork.dhcp.start }}
            DHCP_END: {{ .Values.piholeNetwork.dhcp.end }}
            DHCP_ROUTER: {{ .Values.piholeNetwork.dhcp.gateway }}
            {{- end }}
          {{ with .Values.piholeConfig.additionalEnvs }}
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
              path: /admin/login.php
              port: {{ .Values.piholeNetwork.webPort }}
            readiness:
              enabled: true
              type: http
              path: /admin/login.php
              port: {{ .Values.piholeNetwork.webPort }}
            startup:
              enabled: true
              type: http
              path: /admin/login.php
              port: {{ .Values.piholeNetwork.webPort }}
{{- end -}}
