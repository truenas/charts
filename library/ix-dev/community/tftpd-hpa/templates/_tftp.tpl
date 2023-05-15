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
            capabilities:
              add:
                - NET_BIND_SERVICE
                - SETGID
                - SETUID
                - SYS_CHROOT
          env:
            MAPFILE: ""
            SECURE: "1"
            CREATE: {{ ternary "1" "0" .Values.tftpConfig.allowCreate  | quote }}
          fixedEnv:
            UMASK: {{ ternary "020" "" .Values.tftpConfig.allowCreate  | quote }}
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
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 9069
                                                        "GID" 9069
                                                        "mode" "check"
                                                        "chmod" (ternary "757" "555" .Values.tftpConfig.allowCreate)
                                                        "type" "init") | nindent 8 }}


{{/* Service */}}
service:
  tftp:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: tftp
    ports:
      tftp:
        enabled: true
        primary: true
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
      tftp:
        tftp:
          mountPath: /tftpboot
        01-permissions:
          mountPath: /mnt/directories/tftpboot
{{- end -}}
