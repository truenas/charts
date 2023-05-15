{{- define "tftp.workload" -}}
workload:
  tftp:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.tftpNetwork.hostNetwork }}
      containers:
        tftp:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            # capabilities:
            #   add:
            #     - CHOWN
            #     - DAC_OVERRIDE
            #     - SETUID
            #     - SETGID
            #     - FOWNER
            #     - SYS_CHROOT
            #     - NET_BIND_SERVICE
          {{ with .Values.tftpConfig.additionalEnvs }}
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
              command:
                - /bin/sh
                - -c
                - |
                  getent services tftp
            readiness:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  getent services tftp
            startup:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  getent services tftp

{{/* Service */}}
service:
  tftp:
    enabled: true
    type: NodePort
    targetSelector: tftp
    ports:
      tftp:
        enabled: true
        port: {{ .Values.tftpNetwork.tftpPort }}
        nodePort: {{ .Values.tftpNetwork.tftpPort }}
        targetPort: 69
        protocol: udp
        targetSelector: tftp

{{/* Persistence */}}
persistence:
  tftpboot:
    enabled: true
    type: {{ .Values.tftpStorage.tftpboot.type }}
    datasetName: {{ .Values.tftpStorage.tftpboot.datasetName | default "" }}
    hostPath: {{ .Values.tftpStorage.tftpboot.hostPath | default "" }}
    targetSelector:
      nbxyz:
        nbxyz:
          mountPath: /tftpboot
{{- end -}}
