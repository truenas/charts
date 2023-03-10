{{- define "machinaris.workload" -}}
{{ $allConfig := (include "machinaris.config" $ | fromYaml) }}
{{ $plotDirs := (include "machinaris.plotDirs" $ | fromJsonArray) }}

workload:
  machinaris:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      # This is because machinaris does not support DNS lookups.
      # And all workers need to reach machinaris API by IP.
      # One could set manual ClusterIP IP per worker, but we can't
      # automatically detect free IPs in the cluster.
      # This is unfortunate, as it can potentially bind 3 x number of workers ports on the host.
      hostNetwork: true
      containers:
        machinaris:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            # It also needs to run as root, as it needs to write to /root/.chia
            # Among other privileged operations. Like installing things for workers.
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
          env:
            mode: fullnode
            worker_address: {{ .Values.machNetwork.nodeIP }}
            blockchains: {{ $allConfig.machinaris.blockchains }}
            plots_dir: {{ join ":" $plotDirs | squote }}
          {{ with .Values.machConfig.additionalEnvs }}
            {{ range $env := . }}
            {{ $env.name }}: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: {{ $allConfig.machinaris.apiPort }}
              path: /ping
            readiness:
              enabled: true
              type: http
              port: {{ $allConfig.machinaris.apiPort }}
              path: /ping
            startup:
              enabled: true
              type: http
              port: {{ $allConfig.machinaris.apiPort }}
              path: /ping

{{/* Service */}}
service:
  machinaris:
    enabled: true
    primary: true
    type: ClusterIP
    targetSelector: machinaris
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ $allConfig.machinaris.webPort }}
        # nodePort:
        targetSelector: machinaris
      api:
        enabled: true
        port: {{ $allConfig.machinaris.apiPort }}
        # nodePort:
        targetSelector: machinaris
      farmerPort:
        enabled: true
        port: {{ $allConfig.machinaris.farmerPort }}
        # nodePort:
        targetSelector: machinaris
      networkPort:
        enabled: true
        port: {{ $allConfig.machinaris.networkPort }}
        # nodePort:
        targetSelector: machinaris

{{/* Persistence */}}
persistence:
  {{/* Machinaris config */}}
  machinaris-config:
    enabled: true
    type: {{ .Values.machStorage.config.type }}
    datasetName: {{ .Values.machStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.machStorage.config.hostPath | default "" }}
    targetSelector:
      machinaris:
        machinaris:
          mountPath: /root/.chia
  {{/* Plotting Directory */}}
  plotting:
    enabled: true
    type: {{ .Values.machStorage.plotting.type }}
    datasetName: {{ .Values.machStorage.plotting.datasetName | default "" }}
    hostPath: {{ .Values.machStorage.plotting.hostPath | default "" }}
    mountPath: /plotting
    targetSelectAll: true

  {{/* Mount plot dirs to all pods */}}
  {{ range $idx, $storage := .Values.machStorage.additionalVolumes }}
  {{ printf "%s-%d" $storage.usedFor (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    mountPath: {{ $storage.mountPath }}
    targetSelectAll: true
  {{ end }}

{{- end -}}
