{{- define "chia.workload" -}}
workload:
  chia:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      {{ if or  (lt (int .Values.chiaNetwork.chiaPort) 9000)
                (lt (int .Values.chiaNetwork.farmerPort) 9000) }}
      hostNetwork: true
      {{ else }}
      hostNetwork: false
      {{ end }}
      containers:
        chia:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          env:
            plots_dir: {{ include "chia.plotDirs" $ | quote }}
            {{ with .Values.chiaConfig.full_node_peer }}
            full_node_peer: {{ . | quote }}
            {{ end }}
            {{ with .Values.chiaConfig.service }}
            service: {{ . }}
            {{ end }}
            {{ if eq .Values.chiaConfig.service "harvester" }}
            farmer_address: {{ .Values.chiaConfig.farmer_address | quote }}
            farmer_port: {{ .Values.chiaConfig.farmer_port | quote }}
            ca: {{ .Values.chiaConfig.ca | quote }}
            keys: "none"
            {{ else }}
            keys: {{ include "chia.keyfile" . | quote }}
            {{ end }}
          {{ with .Values.chiaConfig.additionalEnvs }}
            {{ range $env := . }}
            {{ $env.name }}: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  chmod +x /usr/local/bin/docker-healthcheck.sh && \
                  /usr/local/bin/docker-healthcheck.sh || exit 1
            readiness:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  chmod +x /usr/local/bin/docker-healthcheck.sh && \
                  /usr/local/bin/docker-healthcheck.sh || exit 1
            startup:
              enabled: true
              type: exec
              command:
                - /bin/sh
                - -c
                - |
                  chmod +x /usr/local/bin/docker-healthcheck.sh && \
                  /usr/local/bin/docker-healthcheck.sh || exit 1
      {{ if ne .Values.chiaConfig.service "harvester" }}
      initContainers:
        keygen:
          enabled: true
          type: init
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
          command: /bin/sh
          args:
            - -c
            - |
              if [ ! -f {{ include "chia.keyfile" . | quote }} ]; then
                echo "Generating keys..."
                /chia-blockchain/venv/bin/python3 -c \
                  "from chia.util.keychain import generate_mnemonic;print(generate_mnemonic())" > {{ include "chia.keyfile" . | quote }};

                if [ ! -f {{ include "chia.keyfile" . | quote }} ]; then
                 echo "Failed to generate keys." && exit 1
                fi

                echo "Keys generated."
              fi
      {{ end }}
{{/* Service */}}
service:
  chia:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: chia
    ports:
      chia-net:
        enabled: true
        primary: true
        port: {{ .Values.chiaNetwork.chiaPort }}
        nodePort: {{ .Values.chiaNetwork.chiaPort }}
        targePort: 8444
        targetSelector: chia
      chia-farmer:
        enabled: true
        port: {{ .Values.chiaNetwork.farmerPort }}
        nodePort: {{ .Values.chiaNetwork.farmerPort }}
        targePort: 8447
        targetSelector: chia

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    type: {{ .Values.chiaStorage.data.type }}
    datasetName: {{ .Values.chiaStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.chiaStorage.data.hostPath | default "" }}
    targetSelector:
      chia:
        chia:
          mountPath: /root/.chia
  plots:
    enabled: true
    type: {{ .Values.chiaStorage.plots.type }}
    datasetName: {{ .Values.chiaStorage.plots.datasetName | default "" }}
    hostPath: {{ .Values.chiaStorage.plots.hostPath | default "" }}
    targetSelector:
      chia:
        chia:
          mountPath: /plots
        keygen:
          mountPath: /plots
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      chia:
        chia:
          mountPath: /tmp
  {{ range $idx, $vol := .Values.chiaStorage.additionalVolumes }}
  {{ printf "volume-%s" (toString $idx) }}:
    enabled: true
    type: {{ $vol.type }}
    datasetName: {{ $vol.datasetName | default "" }}
    hostPath: {{ $vol.hostPath | default "" }}
    targetSelector:
      chia:
        chia:
          mountPath: {{ $vol.mountPath }}
  {{ end }}
{{- end -}}
