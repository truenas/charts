{{- define "machinaris.coin" -}}
{{ $allConfig := (include "machinaris.config" $ | fromYaml) }}
{{ $plotDirs := (include "machinaris.plotDirs" $ | fromJsonArray) }}

{{ if .Values.machCoins }}
workload:
{{ end }}
{{ range $coin := .Values.machCoins }}
  {{ $coinConfig := (get $allConfig $coin.name) }}
  {{ $coin.name }}:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: true
      containers:
        {{ $coin.name }}:
          enabled: true
          primary: true
          imageSelector: {{ $coinConfig.imageSelector }}
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          env:
            controller_host: {{ $.Values.machNetwork.nodeIP }}
            controller_api_port: {{ $allConfig.machinaris.apiPort }}
            worker_address: {{ $.Values.machNetwork.nodeIP }}
            worker_api_port: {{ $coinConfig.workerPort }}
            blockchains: {{ $coinConfig.blockchains }}
            plots_dir: {{ join ":" $plotDirs | squote }}
          {{ if not (mustHas $coin.config.mode $coinConfig.availableModes) }}
            {{ fail (printf "Invalid mode [%s] for coin [%s]. Available modes: %s" $coin.config.mode $coin.name (join ", " $coinConfig.availableModes)) }}
          {{ end }}
            mode: {{ $coin.config.mode }}
          {{/*
          Mode can be harverster, plotter or "harvester,plotter"
          Only few support plotter tho.
          */}}
          {{ if contains $coin.config.mode "harvester" }}
            farmer_address: {{ $.Values.machNetwork.nodeIP }}
            farmer_api_port: {{ $coinConfig.farmerPort }}
          {{ end }}
          {{ if contains $coin.config.mode "plotter" }}
            {{/* Not sure if those are optional or not. */}}
            {{ with $coin.config.farmerPk }}
            farmer_pk: {{ . }}
            {{ end }}
            {{ with $coin.config.poolPk }}
            pool_pk: {{ . }}
            {{ end }}
            {{ with $coin.config.poolContractAddress }}
            pool_contract_address: {{ . }}
            {{ end }}
          {{ end }}
          {{ with $coin.additionalEnvs }}
            {{ range $env := . }}
            {{ $env.name }}: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              # Might need to disable probes. Depends on when the API is available.
              # (Before or After coin syncing)
              enabled: {{ $coin.config.enableProbes }}
              type: http
              port: {{ $coinConfig.workerPort }}
              path: /ping
            readiness:
              enabled: {{ $coin.config.enableProbes }}
              type: http
              port: {{ $coinConfig.workerPort }}
              path: /ping
            startup:
              enabled: {{ $coin.config.enableProbes }}
              type: http
              port: {{ $coinConfig.workerPort }}
              path: /ping
      initContainers:
        {{ $coin.name }}-init:
          enabled: true
          type: init
          imageSelector: imageCurl
          securityContext:
            runAsUser: 100
            runAsGroup: 101
          resources:
            limits:
              memory: 512Mi
              cpu: 1000m
          command: sh
          args:
            - -c
            - |
              echo "Probing machinaris API..."
              $delay = 3
              until curl -s http://{{ $.Values.machNetwork.nodeIP }}:{{ $allConfig.machinaris.apiPort }}/ping; do
                echo "Waiting for machinaris API... Retrying in $delay seconds..."
                sleep $delay
              done
              echo "Probing machinaris API... Success!"
{{ end }}

{{/* Service */}}
{{ if .Values.machCoins }}
service:
{{ end }}
{{ range $coin := .Values.machCoins }}
  {{ $coinConfig := (get $allConfig $coin.name) }}
  {{ $coin.name }}:
    enabled: true
    type: ClusterIP
    targetSelector: {{ $coin.name }}
    ports:
      worker:
        enabled: true
        primary: true
        port: {{ $coinConfig.workerPort }}
        # nodePort:
        targetSelector: {{ $coin.name }}
      farmer:
        enabled: true
        port: {{ $coinConfig.farmerPort }}
        # nodePort:
        targetSelector: {{ $coin.name }}
      network:
        enabled: true
        port: {{ $coinConfig.networkPort }}
        # nodePort:
        targetSelector: {{ $coin.name }}
{{ end }}

{{/* Persistence */}}
{{ if .Values.machCoins }}
persistence:
{{ end }}
{{ range $coin := .Values.machCoins }}
  {{/* Coin config volume */}}
  {{ printf "%s-config" $coin.name }}:
    enabled: true
    type: {{ $coin.configStorage.type }}
    datasetName: {{ $coin.configStorage.datasetName | default "" }}
    hostPath: {{ $coin.configStorage.hostPath | default "" }}
    targetSelector:
      {{ $coin.name }}:
        {{ $coin.name }}:
          mountPath: /root/.chia

  {{/* Additional coin volumes */}}
  {{ range $idx, $vol := $coin.additionalVolumes }}
  {{ printf "%s-%d" $coin.name (int $idx) }}:
    enabled: true
    type: {{ $vol.type }}
    datasetName: {{ $vol.datasetName | default "" }}
    hostPath: {{ $vol.hostPath | default "" }}
    targetSelector:
      {{ $coin.name }}:
        {{ $coin.name }}:
          mountPath: {{ $vol.mountPath }}
  {{ end }}
{{ end }}

{{- end -}}
