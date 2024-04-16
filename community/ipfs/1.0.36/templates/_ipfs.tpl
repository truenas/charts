{{- define "ipfs.workload" -}}
workload:
  ipfs:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.ipfsNetwork.hostNetwork }}
      containers:
        ipfs:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.ipfsRunAs.user }}
            runAsGroup: {{ .Values.ipfsRunAs.group }}
          {{ with .Values.ipfsConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: exec
              command:
                - ipfs
                - dag
                - stat
                # https://github.com/ipfs/kubo/blob/8f638dcbcd875ecff92021e4b62d0af8848022ce/Dockerfile#L116
                - /ipfs/QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn
            readiness:
              enabled: true
              type: exec
              command:
                - ipfs
                - dag
                - stat
                - /ipfs/QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn
            startup:
              enabled: true
              type: exec
              command:
                - ipfs
                - dag
                - stat
                - /ipfs/QmUNLLsPACCz1vLxQVkXqqLX5R1X345qqfHbsf67hvA3Nn
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.ipfsRunAs.user
                                                        "GID" .Values.ipfsRunAs.group
                                                        "type" "install") | nindent 8 }}
        # "02" prefix is used to ensure this container runs after the permissions container
        02-init-config:
          enabled: true
          type: init
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.ipfsRunAs.user }}
            runAsGroup: {{ .Values.ipfsRunAs.group }}
          command: /init-config.sh
          resources:
            limits:
              memory: 512Mi
              cpu: 1000m
{{/* Service */}}
service:
  ipfs:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: ipfs
    ports:
      api:
        enabled: true
        primary: true
        port: {{ .Values.ipfsNetwork.apiPort }}
        nodePort: {{ .Values.ipfsNetwork.apiPort }}
        targetSelector: ipfs
  ipfs-swarm:
    enabled: true
    type: NodePort
    targetSelector: ipfs
    ports:
      swarm-tcp:
        enabled: true
        primary: true
        port: {{ .Values.ipfsNetwork.swarmPort }}
        nodePort: {{ .Values.ipfsNetwork.swarmPort }}
        targetSelector: ipfs
      swarm-udp:
        enabled: true
        primary: true
        port: {{ .Values.ipfsNetwork.swarmPort }}
        nodePort: {{ .Values.ipfsNetwork.swarmPort }}
        protocol: udp
        targetSelector: ipfs
  ipfs-gateway:
    enabled: true
    type: NodePort
    targetSelector: ipfs
    ports:
      ipfs-gateway:
        enabled: true
        primary: true
        port: {{ .Values.ipfsNetwork.gatewayPort }}
        nodePort: {{ .Values.ipfsNetwork.gatewayPort }}
        targetSelector: ipfs

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    type: {{ .Values.ipfsStorage.data.type }}
    datasetName: {{ .Values.ipfsStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.ipfsStorage.data.hostPath | default "" }}
    targetSelector:
      ipfs:
        ipfs:
          mountPath: /data/ipfs
        01-permissions:
          mountPath: /mnt/directories/data
        02-init-config:
          mountPath: /data/ipfs
  staging:
    enabled: true
    type: {{ .Values.ipfsStorage.staging.type }}
    datasetName: {{ .Values.ipfsStorage.staging.datasetName | default "" }}
    hostPath: {{ .Values.ipfsStorage.staging.hostPath | default "" }}
    targetSelector:
      ipfs:
        ipfs:
          mountPath: /export
        01-permissions:
          mountPath: /mnt/directories/export
  config-script:
    enabled: true
    type: configmap
    objectName: config-script
    defaultMode: "0755"
    targetSelector:
      ipfs:
        02-init-config:
          mountPath: /init-config.sh
          readOnly: true
          subPath: init-config.sh

{{- end -}}
