{{- define "lidarr.workload" -}}
workload:
  lidarr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.lidarrNetwork.hostNetwork }}
      containers:
        lidarr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.lidarrRunAs.user }}
            runAsGroup: {{ .Values.lidarrRunAs.group }}
          env:
            LIDARR__PORT: {{ .Values.lidarrNetwork.webPort }}
            LIDARR__INSTANCE_NAME: {{ .Values.lidarrConfig.instanceName }}
          {{ with .Values.lidarrConfig.additionalEnvs }}
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
              port: "{{ .Values.lidarrNetwork.webPort }}"
              path: /ping
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.lidarrNetwork.webPort }}"
              path: /ping
            startup:
              enabled: true
              type: http
              port: "{{ .Values.lidarrNetwork.webPort }}"
              path: /ping

{{/* Service */}}
service:
  lidarr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: lidarr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.lidarrNetwork.webPort }}
        nodePort: {{ .Values.lidarrNetwork.webPort }}
        targetSelector: lidarr

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    {{- include "lidarr.storage.ci.migration" (dict "storage" .Values.lidarrStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.lidarrStorage.config) | nindent 4 }}
    targetSelector:
      lidarr:
        lidarr:
          mountPath: /config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      lidarr:
        lidarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.lidarrStorage.additionalStorages }}
  {{ printf "lidarr-%v:" (int $idx) }}
    enabled: true
    {{- include "lidarr.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      lidarr:
        lidarr:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "lidarr.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
