{{- define "sonarr.workload" -}}
workload:
  sonarr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.sonarrNetwork.hostNetwork }}
      containers:
        sonarr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.sonarrRunAs.user }}
            runAsGroup: {{ .Values.sonarrRunAs.group }}
          env:
            SONARR__SERVER__PORT: {{ .Values.sonarrNetwork.webPort }}
            SONARR__APP__INSTANCENAME: {{ .Values.sonarrConfig.instanceName }}
          {{ with .Values.sonarrConfig.additionalEnvs }}
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
              port: "{{ .Values.sonarrNetwork.webPort }}"
              path: /ping
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.sonarrNetwork.webPort }}"
              path: /ping
            startup:
              enabled: true
              type: http
              port: "{{ .Values.sonarrNetwork.webPort }}"
              path: /ping
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.sonarrRunAs.user
                                                        "GID" .Values.sonarrRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{/* Service */}}
service:
  sonarr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: sonarr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.sonarrNetwork.webPort }}
        nodePort: {{ .Values.sonarrNetwork.webPort }}
        targetSelector: sonarr

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.sonarrStorage.config) | nindent 4 }}
    targetSelector:
      sonarr:
        sonarr:
          mountPath: /config
        {{- if and (eq .Values.sonarrStorage.config.type "ixVolume")
                  (not (.Values.sonarrStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      sonarr:
        sonarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.sonarrStorage.additionalStorages }}
  {{ printf "sonarr-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      sonarr:
        sonarr:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
