{{- define "tailscale.workload" -}}
{{ include "tailscale.validation" $ }}
workload:
  tailscale:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      automountServiceAccountToken: true
      hostNetwork: {{ .Values.tailscaleNetwork.hostNetwork }}
      sysctls:
        - name: net.ipv4.ip_forward
          value: "1"
        - name: net.ipv6.conf.all.forwarding
          value: "1"
      containers:
        tailscale:
          enabled: true
          primary: true
          imageSelector: image
          command: /usr/local/bin/containerboot
          securityContext:
            {{ if .Values.tailscaleConfig.userspace }}
            runAsUser: 568
            runAsGroup: 568
            {{ else }}
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            {{ end }}
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - NET_ADMIN
                - NET_RAW
          env:
            TS_KUBE_SECRET: {{ printf "%s-tailscale-secret" (include "ix.v1.common.lib.chart.names.fullname" .) }}
            TS_SOCKET: /var/run/tailscale/tailscaled.sock
            TS_USERSPACE: {{ .Values.tailscaleConfig.userspace | quote }}
            TS_ACCEPT_DNS: {{ .Values.tailscaleConfig.acceptDns | quote }}
            TS_AUTH_ONCE: {{ .Values.tailscaleConfig.authOnce | quote }}
            {{ with .Values.tailscaleConfig.advertiseRoutes }}
            TS_ROUTES: {{ join "," . }}
            {{ end }}
            {{ with (include "tailscale.args" $) }}
            TS_EXTRA_ARGS: {{ . }}
            {{ end }}
            {{ with .Values.tailscaleConfig.extraDaemonArgs }}
            TS_TAILSCALED_ARGS: {{ join " " . }}
            {{ end }}
          {{ with .Values.tailscaleConfig.additionalEnvs }}
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
                - tailscale
                - status
            readiness:
              enabled: true
              type: exec
              command:
                - tailscale
                - status
            startup:
              enabled: true
              type: exec
              command:
                - tailscale
                - status

{{/* RBAC */}}
serviceAccount:
  tailscale:
    enabled: true
    primary: true

rbac:
  tailscale:
    enabled: true
    primary: true
    rules:
      - apiGroups:
          - ""
        resources:
          - secrets
        verbs:
          - create
      - apiGroups:
          - ""
        resources:
          - secrets
        resourceNames:
          - {{ printf "%s-tailscale-secret" (include "ix.v1.common.lib.chart.names.fullname" .) }}
        verbs:
          - get
          - update
          - patch

{{/* Persistence */}}
persistence:
  tun-dev:
    enabled: {{ not .Values.tailscaleConfig.userspace }}
    type: device
    hostPath: /dev/net/tun
    targetSelector:
      tailscale:
        tailscale:
          mountPath: /dev/net/tun
  var-run:
    enabled: true
    type: emptyDir
    targetSelector:
      tailscale:
        tailscale:
          mountPath: /var/run
  cache:
    enabled: true
    type: emptyDir
    targetSelector:
      tailscale:
        tailscale:
          mountPath: /.cache

{{/* Secret */}}
secret:
  tailscale-secret:
    enabled: true
    data:
      {{/* Name "authkey" must not be changed, it's what tailscale looks for */}}
      authkey: {{ .Values.tailscaleConfig.authkey }}

{{- end -}}
