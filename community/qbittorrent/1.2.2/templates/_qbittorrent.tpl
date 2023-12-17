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
    {{- include "qbit.storage.ci.migration" (dict "storage" .Values.qbitStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.qbitStorage.config) | nindent 4 }}
    targetSelector:
      qbittorrent:
        qbittorrent:
          mountPath: /config
  downloads:
    enabled: true
    {{- include "qbit.storage.ci.migration" (dict "storage" .Values.qbitStorage.downloads) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.qbitStorage.downloads) | nindent 4 }}
    targetSelector:
      qbittorrent:
        qbittorrent:
          mountPath: /downloads
  {{- range $idx, $storage := .Values.qbitStorage.additionalStorages }}
  {{ printf "qbittorrent-%v:" (int $idx) }}
    enabled: true
    {{- include "qbit.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      qbittorrent:
        qbittorrent:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "qbit.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
