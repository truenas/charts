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
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
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
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.qbitRunAs.user
                                                        "GID" .Values.qbitRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}

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
        01-permissions:
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
        01-permissions:
          mountPath: /mnt/directories/downloads
  {{- range $idx, $storage := .Values.qbitStorage.additionalStorages }}
  {{ printf "qbittorrent-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      qbittorrent:
        qbittorrent:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories/{{ printf "qbittorrent-%v" (int $idx) }}
  {{- end }}
{{- end -}}
