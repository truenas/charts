{{- define "immich.typesense.workload" -}}
{{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}
{{- $url := printf "http://%v-server:%v/server-info/ping" $fullname .Values.immichNetwork.serverPort }}
workload:
  typesense:
    enabled: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        typesense:
          enabled: true
          primary: true
          imageSelector: typesenseImage
          args:
            - --api-port
            - {{ .Values.immichNetwork.typesensePort | quote }}
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
          envFrom:
            - secretRef:
                name: typesense-creds
          probes:
            liveness:
              enabled: true
              type: http
              path: /health
              port: {{ .Values.immichNetwork.typesensePort }}
            readiness:
              enabled: true
              type: http
              path: /health
              port: {{ .Values.immichNetwork.typesensePort }}
            startup:
              enabled: true
              type: http
              path: /health
              port: {{ .Values.immichNetwork.typesensePort }}
{{- end -}}
