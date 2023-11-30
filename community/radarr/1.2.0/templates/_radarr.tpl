{{- define "radarr.workload" -}}
workload:
  radarr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.radarrNetwork.hostNetwork }}
      containers:
        radarr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.radarrRunAs.user }}
            runAsGroup: {{ .Values.radarrRunAs.group }}
          env:
            RADARR__PORT: {{ .Values.radarrNetwork.webPort }}
            RADARR__INSTANCE_NAME: {{ .Values.radarrConfig.instanceName }}
          {{ with .Values.radarrConfig.additionalEnvs }}
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
              port: "{{ .Values.radarrNetwork.webPort }}"
              path: /ping
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.radarrNetwork.webPort }}"
              path: /ping
            startup:
              enabled: true
              type: http
              port: "{{ .Values.radarrNetwork.webPort }}"
              path: /ping

{{/* Service */}}
service:
  radarr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: radarr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.radarrNetwork.webPort }}
        nodePort: {{ .Values.radarrNetwork.webPort }}
        targetSelector: radarr

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    {{- include "radarr.storage.ci.migration" (dict "storage" .Values.radarrStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.radarrStorage.config) | nindent 4 }}
    targetSelector:
      radarr:
        radarr:
          mountPath: /config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      radarr:
        radarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.radarrStorage.additionalStorages }}
  {{ printf "radarr-%v:" (int $idx) }}
    enabled: true
    {{- include "radarr.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      radarr:
        radarr:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "radarr.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
