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
            capabilities:
              add:
                - NET_ADMIN
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
              enabled: true
              type: exec
              command:
                - /gluetun-entrypoint
                - healthcheck
            readiness:
              enabled: true
              type: exec
              command:
                - /gluetun-entrypoint
                - healthcheck
            startup:
              enabled: true
              type: exec
              command:
                - /gluetun-entrypoint
                - healthcheck

{{/* Service */}}


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
{{- end -}}
