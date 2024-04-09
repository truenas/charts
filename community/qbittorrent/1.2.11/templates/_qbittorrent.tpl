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
            {{- if not (hasKey .Values.qbitNetwork "useHttpsProbe") -}}
              {{- $_ := set .Values.qbitNetwork "useHttpsProbe" false -}}
            {{- end }}
            liveness:
              enabled: true
              type: {{ ternary "https" "http" .Values.qbitNetwork.useHttpsProbe }}
              port: "{{ .Values.qbitNetwork.webPort }}"
              path: /
            readiness:
              enabled: true
              type: {{ ternary "https" "http" .Values.qbitNetwork.useHttpsProbe }}
              port: "{{ .Values.qbitNetwork.webPort }}"
              path: /
            startup:
              enabled: true
              type: {{ ternary "https" "http" .Values.qbitNetwork.useHttpsProbe }}
              port: "{{ .Values.qbitNetwork.webPort }}"
              path: /
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.qbitRunAs.user
                                                        "GID" .Values.qbitRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
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
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.qbitStorage.config) | nindent 4 }}
    targetSelector:
      qbittorrent:
        qbittorrent:
          mountPath: /config
        {{- if and (eq .Values.qbitStorage.config.type "ixVolume")
                  (not (.Values.qbitStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  downloads:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.qbitStorage.downloads) | nindent 4 }}
    targetSelector:
      qbittorrent:
        qbittorrent:
          mountPath: /downloads
        {{- if and (eq .Values.qbitStorage.downloads.type "ixVolume")
                  (not (.Values.qbitStorage.downloads.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/downloads
        {{- end }}
  {{- range $idx, $storage := .Values.qbitStorage.additionalStorages }}
  {{ printf "qbittorrent-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      qbittorrent:
        qbittorrent:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
