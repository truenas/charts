{{- define "rsync.workload" -}}
workload:
  rsync:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.rsyncNetwork.hostNetwork }}
      containers:
        rsync:
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
            #     - NET_BIND_SERVICE
            #     - SETGID
            #     - SETUID
            #     - SYS_CHROOT
          probes:
            liveness:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  getent services rsync
            readiness:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  getent services rsync
            startup:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  getent services rsync

{{/* Service */}}
service:
  rsync:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: rsync
    ports:
      rsync:
        enabled: true
        primary: true
        port: {{ .Values.rsyncNetwork.rsyncPort }}
        nodePort: {{ .Values.rsyncNetwork.rsyncPort }}
        protocol: udp
        targetSelector: rsync

{{/* Persistence */}}
persistence:
  temp:
    enabled: true
    type: emptyDir
    targetSelector:
      rsync:
        rsync:
          mountPath: /tmp
  rsync-conf:
    enabled: true
    type: configmap
    objectName: config
    targetSelector:
      rsync:
        rsync:
          mountPath: /etc/rsyncd.conf
          subPath: rsyncd.conf
          readOnly: true
{{- end -}}
