{{- define "syncthing.workload" -}}
workload:
  syncthing:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.syncthingNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.syncthingID.group }}
      containers:
        syncthing:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            # This is needed to allow syncthing assign
            # PCAPs to its child processes
            allowPrivilegeEscalation: true
            capabilities:
              add:
                - FOWNER
                - DAC_OVERRIDE
                - CHOWN
                - SETUID
                - SETGID
                - SETFCAP
                - SETPCAP
                - SYS_ADMIN
          env:
            PCAP: cap_sys_admin,cap_chown,cap_dac_override,cap_fowner+ep
            STGUIADDRESS: "0.0.0.0:{{ .Values.syncthingNetwork.webPort }}"
            # Set a custom override for the GUI assets
            STGUIASSETS: /var/truenas/assets/gui
            # Disable automatic upgrades
            STNOUPGRADE: "true"
          fixedEnv:
            PUID: {{ .Values.syncthingID.user }}
          {{ with .Values.syncthingConfig.additionalEnvs }}
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
              path: /rest/noauth/health
              port: "{{ .Values.syncthingNetwork.webPort }}"
            readiness:
              enabled: true
              type: http
              path: /rest/noauth/health
              port: "{{ .Values.syncthingNetwork.webPort }}"
            startup:
              enabled: true
              type: http
              path: /rest/noauth/health
              port: "{{ .Values.syncthingNetwork.webPort }}"
          # We use this hook as we need the API
          # to be running when we run the configure script
          lifecycle:
            postStart:
              type: exec
              command:
                - su-exec
                - "{{ .Values.syncthingID.user }}:{{ .Values.syncthingID.group }}"
                - /configure.sh
      {{- if .Values.syncthingNetwork.certificateID }}
      initContainers:
        {{- include "syncthing.certContainer" $ | nindent 8 -}}
      {{- end }}
{{- end -}}
