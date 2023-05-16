{{- define "gluetun.workload" -}}
workload:
  gluetun:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.gluetunNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.gluetunID.group }}
      containers:
        gluetun:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - NET_ADMIN
                - DAC_OVERRIDE
          fixedEnv:
            PUID: {{ .Values.gluetunID.user }}
          envFrom:
            - configMapRef:
                name: gluetun
          {{ with .Values.gluetunConfig.additionalEnvs }}
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
                - /gluetun-entrypoint
                - healthcheck
            readiness:
              enabled: {{ not .Values.ci }}
              type: exec
              command:
                - /gluetun-entrypoint
                - healthcheck
            startup:
              enabled: {{ not .Values.ci }}
              type: exec
              command:
                - /gluetun-entrypoint
                - healthcheck

{{/* Persistence */}}
persistence:
  devtun:
    enabled: true
    type: device
    hostPath: /dev/net/tun
    targetSelector:
      gluetun:
        gluetun:
          mountPath: /dev/net/tun
  data:
    enabled: true
    type: {{ .Values.gluetunStorage.data.type }}
    datasetName: {{ .Values.gluetunStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.gluetunStorage.data.hostPath | default "" }}
    targetSelector:
      gluetun:
        gluetun:
          mountPath: /gluetun
  temp:
    enabled: true
    type: emptyDir
    targetSelector:
      gluetun:
        gluetun:
          mountPath: /tmp/gluetun
{{- end -}}
