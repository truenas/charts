{{- define "tdarr.workload" -}}
workload:
  tdarr:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      securityContext:
        fsGroup: {{ .Values.tdarrID.group }}
      containers:
        tdarr:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            readOnlyRootFilesystem: false
            runAsNonRoot: false
            capabilities:
              add:
                - CHOWN
                - FOWNER
                - SETUID
                - SETGID
          env:
            inContainer: "true"
            internalNode: {{ .Values.tdarrConfig.internalNode | quote }}
            serverPort: {{ .Values.tdarrNetwork.serverPort }}
            webUIPort: {{ .Values.tdarrNetwork.webPort }}
            nodeName: {{ .Values.tdarrConfig.nodeName }}
            serverIP: {{ .Values.tdarrConfig.serverIP }}
          fixedEnv:
            PUID: {{ .Values.tdarrID.user }}
          {{ with .Values.tdarrConfig.additionalEnvs }}
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
              port: "{{ .Values.tdarrNetwork.webPort }}"
              path: /api/v2/status
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.tdarrNetwork.webPort }}"
              path: /api/v2/status
            startup:
              enabled: true
              type: http
              port: "{{ .Values.tdarrNetwork.webPort }}"
              path: /api/v2/status

{{/* Service */}}
service:
  tdarr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: tdarr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.tdarrNetwork.webPort }}
        nodePort: {{ .Values.tdarrNetwork.webPort }}
        targetSelector: tdarr
      server:
        enabled: true
        port: {{ .Values.tdarrNetwork.serverPort }}
        nodePort: {{ .Values.tdarrNetwork.serverPort }}
        targetSelector: tdarr

{{/* Persistence */}}
persistence:
  server:
    enabled: true
    {{- include "tdarr.storage.ci.migration" (dict "storage" .Values.tdarrStorage.server) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.tdarrStorage.server) | nindent 4 }}
    targetSelector:
      tdarr:
        tdarr:
          mountPath: /app/server
  configs:
    enabled: true
    {{- include "tdarr.storage.ci.migration" (dict "storage" .Values.tdarrStorage.configs) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.tdarrStorage.configs) | nindent 4 }}
    targetSelector:
      tdarr:
        tdarr:
          mountPath: /app/configs
  logs:
    enabled: true
    {{- include "tdarr.storage.ci.migration" (dict "storage" .Values.tdarrStorage.logs) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.tdarrStorage.logs) | nindent 4 }}
    targetSelector:
      tdarr:
        tdarr:
          mountPath: /app/logs
  transcode:
    enabled: true
    {{- include "tdarr.storage.ci.migration" (dict "storage" .Values.tdarrStorage.transcodes) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.tdarrStorage.transcodes) | nindent 4 }}
    targetSelector:
      tdarr:
        tdarr:
          mountPath: /temp
  {{- range $idx, $storage := .Values.tdarrStorage.additionalStorages }}
  {{ printf "tdarr-%v" (int $idx) }}:
    enabled: true
    {{- include "tdarr.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      tdarr:
        tdarr:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

{{ with .Values.tdarrGPU }}
scaleGPU:
  {{ range $key, $value := . }}
  - gpu:
      {{ $key }}: {{ $value }}
    targetSelector:
      tdarr:
        - tdarr
  {{ end }}
{{ end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "tdarr.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}

  {{- if eq $storage.type "emptyDir" -}}
    {{- if not $storage.emptyDirConfig -}}
      {{- $_ := set $storage "emptyDirConfig" (dict "medium" "" "size" "") -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
