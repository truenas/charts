{{- define "nbxyz.workload" -}}
workload:
  nbxyz:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.nbxyzNetwork.hostNetwork }}
      containers:
        nbxyz:
          enabled: true
          primary: true
          imageSelector: image
          command: /init.sh
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - DAC_OVERRIDE
                - SETUID
                - SETGID
                - FOWNER
                - SYS_CHROOT
                - NET_BIND_SERVICE
          {{ with .Values.nbxyzConfig.additionalEnvs }}
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
              port: 3000
              path: /
            readiness:
              enabled: true
              type: http
              port: 3000
              path: /
            startup:
              enabled: true
              type: http
              port: 3000
              path: /

{{/* Service */}}
service:
  nbxyz:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: nbxyz
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.nbxyzNetwork.webPort }}
        nodePort: {{ .Values.nbxyzNetwork.webPort }}
        targetPort: 3000
        targetSelector: nbxyz
      assets:
        enabled: true
        port: {{ .Values.nbxyzNetwork.assetsPort }}
        nodePort: {{ .Values.nbxyzNetwork.assetsPort }}
        targetSelector: nbxyz
  tftp:
    enabled: true
    type: NodePort
    targetSelector: nbxyz
    ports:
      tftp:
        enabled: true
        port: {{ .Values.nbxyzNetwork.tftpPort }}
        nodePort: {{ .Values.nbxyzNetwork.tftpPort }}
        targetPort: 69
        protocol: udp
        targetSelector: nbxyz

{{/* Persistence */}}
persistence:
  init:
    enabled: true
    type: configmap
    objectName: init
    defaultMode: "0755"
    targetSelector:
      nbxyz:
        nbxyz:
          mountPath: /init.sh
          subPath: init.sh
          readOnly: true
  config:
    enabled: true
    type: {{ .Values.nbxyzStorage.config.type }}
    datasetName: {{ .Values.nbxyzStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.nbxyzStorage.config.hostPath | default "" }}
    targetSelector:
      nbxyz:
        nbxyz:
          mountPath: /config
  assets:
    enabled: true
    type: {{ .Values.nbxyzStorage.assets.type }}
    datasetName: {{ .Values.nbxyzStorage.assets.datasetName | default "" }}
    hostPath: {{ .Values.nbxyzStorage.assets.hostPath | default "" }}
    targetSelector:
      nbxyz:
        nbxyz:
          mountPath: /assets
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      nbxyz:
        nbxyz:
          mountPath: /tmp
{{- end -}}
