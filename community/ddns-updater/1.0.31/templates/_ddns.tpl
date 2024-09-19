{{- define "ddns.workload" -}}
workload:
  ddns:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.ddnsNetwork.hostNetwork }}
      containers:
        ddns:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.ddnsRunAs.user }}
            runAsGroup: {{ .Values.ddnsRunAs.group }}
          env:
            LISTENING_ADDRESS: {{ printf ":%v" .Values.ddnsNetwork.webPort }}
            DATADIR: /updater/data
            BACKUP_DIRECTORY: /updater/data
          envFrom:
            - configMapRef:
                name: ddns-config
          {{ with .Values.ddnsConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: {{ not .Values.ci }}
              type: exec
              command:
                - /updater/ddns-updater
                - healthcheck
            readiness:
              enabled: {{ not .Values.ci }}
              type: exec
              command:
                - /updater/ddns-updater
                - healthcheck
            startup:
              enabled: {{ not .Values.ci }}
              type: exec
              command:
                - /updater/ddns-updater
                - healthcheck
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.ddnsRunAs.user
                                                        "GID" .Values.ddnsRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}

{{/* Service */}}
service:
  ddns:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: ddns
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.ddnsNetwork.webPort }}
        nodePort: {{ .Values.ddnsNetwork.webPort }}
        targetSelector: ddns

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    type: {{ .Values.ddnsStorage.data.type }}
    datasetName: {{ .Values.ddnsStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.ddnsStorage.data.hostPath | default "" }}
    targetSelector:
      ddns:
        ddns:
          mountPath: /updater/data
        01-permissions:
          mountPath: /mnt/directories/data
{{- end -}}
