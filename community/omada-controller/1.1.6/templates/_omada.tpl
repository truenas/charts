{{- define "omada.workload" -}}
workload:
  omada:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.omadaNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.omadaID.group }}
      containers:
        omada:
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
              - CHOWN
              - DAC_OVERRIDE
              - FOWNER
              - SETUID
              - SETGID
          fixedEnv:
            PUID: {{ .Values.omadaID.user }}
          env:
            PUSERNAME: omada
            PGROUP: omada
            MANAGE_HTTP_PORT: {{ .Values.omadaNetwork.manageHttpPort }}
            MANAGE_HTTPS_PORT: {{ .Values.omadaNetwork.manageHttpsPort }}
            PORTAL_HTTP_PORT: {{ .Values.omadaNetwork.portalHttpPort }}
            PORTAL_HTTPS_PORT: {{ .Values.omadaNetwork.portalHttpsPort }}
            PORT_APP_DISCOVERY: {{ .Values.omadaNetwork.appDiscoveryPort }}
            PORT_DISCOVERY: {{ .Values.omadaNetwork.discoveryPort }}
            PORT_MANAGER_V2: {{ .Values.omadaNetwork.managerV2Port }}
            PORT_ADOPT_V1: {{ .Values.omadaNetwork.adoptV1Port }}
            PORT_MANAGER_V1: {{ .Values.omadaNetwork.managerV1Port }}
            PORT_UPGRADE_V1: {{ .Values.omadaNetwork.upgradeV1Port }}
            {{- if .Values.omadaNetwork.certificateID }}
            SSL_CERT_NAME: tls.crt
            SSL_KEY_NAME: tls.key
            {{- end }}
          {{ with .Values.omadaConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: exec
              command: /healthcheck.sh
            readiness:
              enabled: true
              type: exec
              command: /healthcheck.sh
            startup:
              enabled: true
              type: exec
              command: /healthcheck.sh
{{- end -}}
