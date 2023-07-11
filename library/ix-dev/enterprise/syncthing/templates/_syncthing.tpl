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
          env:
            PCAP: cap_chown,cap_dac_override,cap_fowner+ep
            STGUIADDRESS: "0.0.0.0:{{ .Values.syncthingNetwork.webPort }}"
            # Disable automatic upgrades
            STNOUPGRADE: "true"
          fixedEnv:
            PUID: {{ .Values.syncthingID.user }}
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
{{/* Service */}}
service:
  syncthing-web:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: syncthing
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.syncthingNetwork.webPort }}
        nodePort: {{ .Values.syncthingNetwork.webPort }}
        targetSelector: syncthing
  syncthing-discovery:
    # Only enable this service if local discovery is enabled
    enabled: {{ .Values.syncthingConfig.localDiscovery }}
    type: NodePort
    targetSelector: syncthing
    ports:
      discovery:
        enabled: true
        port: {{ .Values.syncthingNetwork.localDiscoveryPort }}
        nodePort: {{ .Values.syncthingNetwork.localDiscoveryPort }}
        targetPort: 21017
        protocol: udp
        targetSelector: syncthing
  syncthing-transfer:
    enabled: true
    type: NodePort
    targetSelector: syncthing
    ports:
      tcp:
        enabled: true
        primary: true
        port: {{ .Values.syncthingNetwork.tcpPort }}
        nodePort: {{ .Values.syncthingNetwork.tcpPort }}
        targetPort: 22000
        targetSelector: syncthing
      quic:
        enabled: true
        port: {{ .Values.syncthingNetwork.quicPort }}
        nodePort: {{ .Values.syncthingNetwork.quicPort }}
        targetPort: 22000
        protocol: udp
        targetSelector: syncthing
{{- end -}}
