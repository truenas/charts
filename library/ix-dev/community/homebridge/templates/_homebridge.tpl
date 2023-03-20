{{- define "homebridge.workload" -}}
workload:
  homebridge:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.hbNetwork.hostNetwork }}
      containers:
        homebridge:
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
                # Without those, logs show: "Failed to start message bus: Failed to drop capabilities: Operation not permitted"
                - SETGID
                - SETUID
                # Witout this, logs show: "Failed to start message bus: Failed to bind socket "/var/run/dbus/system_bus_socket": Permission denied"
                - DAC_OVERRIDE
                {{ if .Values.hbConfig.enableAvahi }}
                # Without this, logs show: "Failed to create runtime directory /run/avahi-daemon"
                - CHOWN
                {{ end }}
          env:
            HOMEBRIDGE_CONFIG_UI_PORT: {{ .Values.hbNetwork.webPort }}
            ENABLE_AVAHI: {{ ternary "1" "0" .Values.hbConfig.enableAvahi | quote }}
          {{ with .Values.hbConfig.additionalEnvs }}
            {{ range $env := . }}
            {{ $env.name }}: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: {{ .Values.hbNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: http
              port: {{ .Values.hbNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: http
              port: {{ .Values.hbNetwork.webPort }}
              path: /

{{/* Service */}}
service:
  homebridge:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: homebridge
    ports:
      homebridge:
        enabled: true
        primary: true
        port: {{ .Values.hbNetwork.webPort }}
        nodePort: {{ .Values.hbNetwork.webPort }}
        targetSelector: homebridge

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    type: {{ .Values.hbStorage.data.type }}
    datasetName: {{ .Values.hbStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.hbStorage.data.hostPath | default "" }}
    targetSelector:
      homebridge:
        homebridge:
          mountPath: /homebridge
{{- end -}}
