{{- define "mineos.workload" -}}
workload:
  mineos:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      # Upstream recommends a large termination grace period
      terminationGracePeriodSeconds: {{ .Values.mineosConfig.terminationGracePeriodSeconds }}
      securityContext:
        fsGroup: {{ .Values.mineosID.group }}
      containers:
        mineos:
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
                - SETGID
                - SETUID
          env:
            SERVER_PORT: {{ .Values.mineosNetwork.webPort }}
            USER_UID: {{ .Values.mineosID.user }}
            GROUP_GID: {{ .Values.mineosID.group }}
            USER_NAME: {{ .Values.mineosConfig.username }}
            USER_PASSWORD: {{ .Values.mineosConfig.password }}
            # Creates a group with the same name as the user
            GROUP_NAME: {{ .Values.mineosConfig.username }}
            USE_HTTPS: {{ .Values.mineosNetwork.useHTTPS }}
          fixedEnv:
            PUID: {{ .Values.mineosID.user }}
          {{ with .Values.mineosConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: tcp
              port: {{ .Values.mineosNetwork.webPort }}
            readiness:
              enabled: true
              type: tcp
              port: {{ .Values.mineosNetwork.webPort }}
            startup:
              enabled: true
              type: tcp
              port: {{ .Values.mineosNetwork.webPort }}

{{/* Service */}}
service:
  mineos:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: mineos
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.mineosNetwork.webPort }}
        nodePort: {{ .Values.mineosNetwork.webPort }}
        targetSelector: mineos
  game:
    enabled: true
    type: NodePort
    targetSelector: mineos
    ports:
  {{- $start := (.Values.mineosNetwork.mineosPortRangeStart | int) -}}
  {{- $end := (.Values.mineosNetwork.mineosPortRangeEnd | int) -}}
  {{- $ports := (untilStep $start ($end | add1 | int) 1) -}}
  {{- range $idx := $ports }}
      port-{{ $idx }}-tcp:
        enabled: true
        primary: {{ eq $idx $start }}
        port: {{ $idx }}
        nodePort: {{ $idx }}
        targetSelector: mineos
      port-{{ $idx }}-udp:
        enabled: true
        primary: false
        port: {{ $idx }}
        nodePort: {{ $idx }}
        protocol: udp
        targetSelector: mineos
  {{- end }}

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    type: {{ .Values.mineosStorage.data.type }}
    datasetName: {{ .Values.mineosStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.mineosStorage.data.hostPath | default "" }}
    targetSelector:
      mineos:
        mineos:
          mountPath: /var/games/minecraft

  {{- if and .Values.mineosNetwork.useHTTPS .Values.mineosNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: mineos-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: mineos.key
      - key: tls.crt
        path: mineos.crt
    targetSelector:
      mineos:
        mineos:
          mountPath: /etc/ssl/certs
          readOnly: true

scaleCertificate:
  mineos-cert:
    enabled: true
    id: {{ .Values.mineosNetwork.certificateID }}
    {{- end -}}
{{- end -}}
