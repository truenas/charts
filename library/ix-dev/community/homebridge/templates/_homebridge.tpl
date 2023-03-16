{{- define "homebridge.workload" -}}
workload:
  homebridge:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: true
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
                - CHOWN
                - SETGID
                - SETUID
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
