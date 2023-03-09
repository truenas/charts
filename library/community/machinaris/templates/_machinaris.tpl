{{- define "machinaris.workload" -}}
workload:
  machinaris:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.ipfs_network.hostNetwork }}
      containers:
        machinaris:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
          {{ with .Values.ipfs_config.additionalEnvs }}
          env:
            {{ range $env := . }}
            {{ $env.name }}: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: false
            readiness:
              enabled: false
            startup:
              enabled: false
      # initContainers:
{{/* Service */}}
service:
  machinaris:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: machinaris
    ports:
      api:
        enabled: true
        primary: true
        port: {{ .Values.machinaris_network.apiPort }}
        nodePort: {{ .Values.machinaris_network.apiPort }}
        targetSelector: machinaris

{{/* Persistence */}}
persistence:
  config:
    enabled: true
    type: {{ .Values.machinaris_storage.data.type }}
    datasetName: {{ .Values.machinaris_storage.data.datasetName | default "" }}
    hostPath: {{ .Values.machinaris_storage.data.hostPath | default "" }}
    targetSelector:
      machinaris:
        machinaris:
          mountPath: /root/.chia

{{- end -}}
