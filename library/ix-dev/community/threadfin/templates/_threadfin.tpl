{{- define "threadfin.workload" -}}
workload:
  threadfin:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.threadfinNetwork.hostNetwork }}
      containers:
        threadfin:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.threadfinRunAs.user }}
            runAsGroup: {{ .Values.threadfinRunAs.group }}
          env:
            THREADFIN__SERVER__PORT: {{ .Values.threadfinNetwork.webPort }}
            THREADFIN__APP__INSTANCENAME: {{ .Values.threadfinConfig.instanceName }}
          {{ with .Values.threadfinConfig.additionalEnvs }}
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
              port: "{{ .Values.threadfinNetwork.webPort }}"
              path: /ping
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.threadfinNetwork.webPort }}"
              path: /ping
            startup:
              enabled: true
              type: http
              port: "{{ .Values.threadfinNetwork.webPort }}"
              path: /ping
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.threadfinRunAs.user
                                                        "GID" .Values.threadfinRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{/* Service */}}
service:
  threadfin:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: threadfin
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.threadfinNetwork.webPort }}
        nodePort: {{ .Values.threadfinNetwork.webPort }}
        targetSelector: threadfin

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.threadfinStorage.config) | nindent 4 }}
    targetSelector:
      threadfin:
        threadfin:
          mountPath: /home/threadfin/conf
        {{- if and (eq .Values.threadfinStorage.config.type "ixVolume")
                  (not (.Values.threadfinStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      threadfin:
        threadfin:
          mountPath: /tmp/threadfin
  {{- range $idx, $storage := .Values.threadfinStorage.additionalStorages }}
  {{ printf "threadfin-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      threadfin:
        threadfin:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
