{{- define "immich.machinelearning.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $url := printf "http://%v-server:%v/server-info/ping" $fullname .Values.immichNetwork.serverPort }}
workload:
  machinelearning:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        machinelearning:
          enabled: true
          primary: true
          imageSelector: mlImage
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          envFrom:
            - configMapRef:
                name: ml-config
          probes:
            liveness:
              enabled: true
              type: http
              port: {{ .Values.immichNetwork.machinelearningPort }}
              path: /ping
            readiness:
              enabled: true
              type: http
              port: {{ .Values.immichNetwork.machinelearningPort }}
              path: /ping
            startup:
              enabled: true
              type: http
              port: {{ .Values.immichNetwork.machinelearningPort }}
              path: /ping
      initContainers:
      {{- include "immich.wait.init" (dict "url" $url) | indent 8 }}
{{- end -}}
