{{- define "deluge.workload" -}}
workload:
  deluge:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      securityContext:
        fsGroup: {{ .Values.delugeID.group }}
      hostNetwork: {{ .Values.delugeNetwork.hostNetwork }}
      containers:
        deluge:
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
          {{ with .Values.delugeConfig.additionalEnvs }}
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
              port: 8112
              path: /
            readiness:
              enabled: true
              type: http
              port: 8112
              path: /
            startup:
              enabled: true
              type: http
              port: 8112
              path: /

{{/* Service */}}
service:
  deluge:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: deluge
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.delugeNetwork.webPort }}
        nodePort: {{ .Values.delugeNetwork.webPort }}
        targetPort: 8112
        targetSelector: deluge
      {{- if .Values.delugeNetwork.exposeDaemon }}
      daemon:
        enabled: true
        port: {{ .Values.delugeNetwork.daemonPort }}
        nodePort: {{ .Values.delugeNetwork.daemonPort }}
        targetPort: 58846
        targetSelector: deluge
      {{- end }}
  torrent:
    enabled: true
    type: NodePort
    targetSelector: deluge
    ports:
      tcp:
        enabled: true
        primary: true
        port: {{ .Values.delugeNetwork.torrentPort }}
        nodePort: {{ .Values.delugeNetwork.torrentPort }}
        targetPort: 6881
        targetSelector: deluge
      udp:
        enabled: true
        port: {{ .Values.delugeNetwork.torrentPort }}
        nodePort: {{ .Values.delugeNetwork.torrentPort }}
        targetPort: 6881
        protocol: udp
        targetSelector: deluge

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    type: {{ .Values.delugeStorage.config.type }}
    datasetName: {{ .Values.delugeStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.delugeStorage.config.hostPath | default "" }}
    targetSelector:
      deluge:
        deluge:
          mountPath: /config
  downloads:
    enabled: true
    type: {{ .Values.delugeStorage.downloads.type }}
    datasetName: {{ .Values.delugeStorage.downloads.datasetName | default "" }}
    hostPath: {{ .Values.delugeStorage.downloads.hostPath | default "" }}
    targetSelector:
      deluge:
        deluge:
          mountPath: /downloads
  {{- range $idx, $storage := .Values.delugeStorage.additionalStorages }}
  {{ printf "deluge-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      deluge:
        deluge:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
