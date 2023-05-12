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
    type: {{ .Values.tdarrStorage.server.type }}
    datasetName: {{ .Values.tdarrStorage.server.datasetName | default "" }}
    hostPath: {{ .Values.tdarrStorage.server.hostPath | default "" }}
    targetSelector:
      tdarr:
        tdarr:
          mountPath: /app/server
  configs:
    enabled: true
    type: {{ .Values.tdarrStorage.configs.type }}
    datasetName: {{ .Values.tdarrStorage.configs.datasetName | default "" }}
    hostPath: {{ .Values.tdarrStorage.configs.hostPath | default "" }}
    targetSelector:
      tdarr:
        tdarr:
          mountPath: /app/configs
  logs:
    enabled: true
    type: {{ .Values.tdarrStorage.logs.type }}
    datasetName: {{ .Values.tdarrStorage.logs.datasetName | default "" }}
    hostPath: {{ .Values.tdarrStorage.logs.hostPath | default "" }}
    targetSelector:
      tdarr:
        tdarr:
          mountPath: /app/logs
  transcode:
    enabled: true
    type: {{ .Values.tdarrStorage.transcodes.type }}
    datasetName: {{ .Values.tdarrStorage.transcodes.datasetName | default "" }}
    hostPath: {{ .Values.tdarrStorage.transcodes.hostPath | default "" }}
    medium: {{ .Values.tdarrStorage.transcodes.medium | default "" }}
    {{/* Size of the emptyDir */}}
    size: {{ .Values.tdarrStorage.transcodes.size | default "" }}
    targetSelector:
      tdarr:
        tdarr:
          mountPath: /temp
  {{- range $idx, $storage := .Values.tdarrStorage.additionalStorages }}
  {{ printf "tdarr-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
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
