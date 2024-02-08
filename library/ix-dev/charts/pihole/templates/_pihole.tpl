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
            capabilities:
              add:
                - NET_ADMIN
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - SETGID
                - SETUID
                - KILL
          env:
            WEB_PORT: {{ .Values.piholeNetwork.webPort }}
            WEBPASSWORD: {{ .Values.piholeConfig.webPassword }}
            {{- if .Values.piholeNetwork.enableDHCP }}
            DHCP_ACTIVE: "true"
            DHCP_START: {{ .Values.piholeNetwork.dhcpStart }}
            DHCP_END: {{ .Values.piholeNetwork.dhcpEnd }}
            DHCP_ROUTER: {{ .Values.piholeNetwork.dhcpGateway }}
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
