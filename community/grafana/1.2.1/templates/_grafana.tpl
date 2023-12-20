{{- define "grafana.workload" -}}
workload:
  grafana:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.grafanaNetwork.hostNetwork }}
      containers:
        grafana:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.grafanaRunAs.user }}
            runAsGroup: {{ .Values.grafanaRunAs.group }}
          envFrom:
            - configMapRef:
                name: grafana-config
          {{ with .Values.grafanaConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            {{ $scheme := "http" }}
            {{ if .Values.grafanaNetwork.certificateID }}
              {{ $scheme = "https" }}
            {{ end }}
            liveness:
              enabled: true
              type: {{ $scheme }}
              port: {{ .Values.grafanaNetwork.webPort }}
              path: /api/health
            readiness:
              enabled: true
              type: {{ $scheme }}
              port: {{ .Values.grafanaNetwork.webPort }}
              path: /api/health
            startup:
              enabled: true
              type: {{ $scheme }}
              port: {{ .Values.grafanaNetwork.webPort }}
              path: /api/health
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.grafanaRunAs.user
                                                        "GID" .Values.grafanaRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}

{{/* Service */}}
service:
  grafana:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: grafana
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.grafanaNetwork.webPort }}
        nodePort: {{ .Values.grafanaNetwork.webPort }}
        targetSelector: grafana

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.grafanaStorage.data) | nindent 4 }}
    targetSelector:
      grafana:
        grafana:
          mountPath: /var/lib/grafana
        {{- if and (eq .Values.grafanaStorage.data.type "ixVolume")
                  (not (.Values.grafanaStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      grafana:
        grafana:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.grafanaStorage.additionalStorages }}
  {{ printf "grafana-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      grafana:
        grafana:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
  {{- if .Values.grafanaNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: grafana-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: tls.key
      - key: tls.crt
        path: tls.crt
    targetSelector:
      grafana:
        grafana:
          mountPath: /grafana/certs
          readOnly: true

scaleCertificate:
  grafana-cert:
    enabled: true
    id: {{ .Values.grafanaNetwork.certificateID }}
    {{- end -}}
{{- end -}}
