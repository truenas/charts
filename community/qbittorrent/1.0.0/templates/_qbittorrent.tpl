{{- define "qbittorrent.workload" -}}
workload:
  qbittorrent:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.qbitNetwork.hostNetwork }}
      containers:
        qbittorrent:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.qbitRunAs.user }}
            runAsGroup: {{ .Values.qbitRunAs.group }}
          {{ with .Values.qbitConfig.additionalEnvs }}
          env:
            {{ range $env := . }}
            {{ $env.name }}: {{ $env.value }}
            {{ end }}
          {{ end }}
          envFrom:
            - configMapRef:
                name: qbit-config
          probes:
            liveness:
              enabled: true
              type: http
              port: "{{ .Values.qbitNetwork.webPort }}"
              path: /
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.qbitNetwork.webPort }}"
              path: /
            startup:
              enabled: true
              type: http
              port: "{{ .Values.qbitNetwork.webPort }}"
              path: /
      initContainers:
        check-permissions:
          enabled: true
          type: init
          imageSelector: bashImage
          resources:
            limits:
              cpu: 1000m
              memory: 512Mi
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
          command: bash
          args:
            - -c
            - |
              for dir in /mnt/directories/*; do
                if [ ! -d "$dir" ]; then
                  echo "[$dir] is not a directory, skipping"
                  continue
                fi

                if [ $(stat -c %u "$dir") -eq {{ .Values.qbitRunAs.user }} ] && [ $(stat -c %g "$dir") -eq {{ .Values.qbitRunAs.group }} ]; then
                  echo "Permissions on ["$dir"] are correct"
                else
                  echo "Permissions on ["$dir"] are incorrect"
                  echo "Changing ownership to {{ .Values.qbitRunAs.user }}:{{ .Values.qbitRunAs.group }} on the following directories: ["$dir"]"
                  chown -R {{ .Values.qbitRunAs.user }}:{{ .Values.qbitRunAs.group }} "$dir"
                  echo "Finished changing ownership"
                  echo "Permissions after changing ownership:"
                  stat -c "%u %g" "$dir"
                fi
              done

{{/* Service */}}
service:
  qbittorrent:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: qbittorrent
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.qbitNetwork.webPort }}
        nodePort: {{ .Values.qbitNetwork.webPort }}
        targetSelector: qbittorrent
  qbittorrent-bt:
    enabled: true
    type: NodePort
    targetSelector: qbittorrent
    ports:
      bt-tcp:
        enabled: true
        primary: true
        port: {{ .Values.qbitNetwork.btPort }}
        nodePort: {{ .Values.qbitNetwork.btPort }}
        targetSelector: qbittorrent
      bt-upd:
        enabled: true
        primary: true
        port: {{ .Values.qbitNetwork.btPort }}
        nodePort: {{ .Values.qbitNetwork.btPort }}
        protocol: udp
        targetSelector: qbittorrent

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    type: {{ .Values.qbitStorage.config.type }}
    datasetName: {{ .Values.qbitStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.qbitStorage.config.hostPath | default "" }}
    targetSelector:
      qbittorrent:
        qbittorrent:
          mountPath: /config
        check-permissions:
          mountPath: /mnt/directories/config
  downloads:
    enabled: true
    type: {{ .Values.qbitStorage.downloads.type }}
    datasetName: {{ .Values.qbitStorage.downloads.datasetName | default "" }}
    hostPath: {{ .Values.qbitStorage.downloads.hostPath | default "" }}
    targetSelector:
      qbittorrent:
        qbittorrent:
          mountPath: /downloads
        check-permissions:
          mountPath: /mnt/directories/downloads
{{- end -}}
