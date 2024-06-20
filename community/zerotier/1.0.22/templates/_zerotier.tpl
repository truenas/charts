{{- define "zerotier.workload" -}}
workload:
  zerotier:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.zerotierNetwork.hostNetwork }}
      sysctls:
        - name: net.ipv4.ip_forward
          value: "1"
        - name: net.ipv6.conf.all.forwarding
          value: "1"
      containers:
        zerotier:
          enabled: true
          primary: true
          imageSelector: image
          args:
          {{ if not .Values.zerotierConfig.networks }}
            {{ fail "Zerotier - At least one network must be specified" }}
          {{ end }}
          {{ range .Values.zerotierConfig.networks }}
          - {{ . }}
          {{ end }}
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                {{/* Most of those capabilities are normally added by default in conainers
                But by default, in common, we drop all of them. So here we add some of them
                as they are needed, because zerotier starts as root but drops privs for some
                of the processes running by the zerotier binary */}}
                - AUDIT_WRITE
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - NET_ADMIN
                - NET_BIND_SERVICE
                - NET_RAW
                - SETGID
                - SETPCAP
                - SETUID
                - SYS_ADMIN
          env:
            {{ with .Values.zerotierConfig.authToken }}
            ZEROTIER_API_SECRET: {{ . }}
            {{ end }}
            {{ with .Values.zerotierConfig.identityPublic }}
            ZEROTIER_IDENTITY_PUBLIC: {{ . }}
            {{ end }}
            {{ with .Values.zerotierConfig.identitySecret }}
            ZEROTIER_IDENTITY_SECRET: {{ . }}
            {{ end }}
          {{ with .Values.zerotierConfig.additionalEnvs }}
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
              command: /healthcheck.sh
            readiness:
              enabled: true
              type: exec
              command: /healthcheck.sh
            startup:
              enabled: true
              type: exec
              command: /healthcheck.sh

{{/* Persistence */}}
persistence:
  tun-dev:
    enabled: true
    type: device
    hostPath: /dev/net/tun
    targetSelector:
      zerotier:
        zerotier:
          mountPath: /dev/net/tun
  {{- range $idx, $storage := .Values.zerotierStorage.additionalStorages }}
  {{ printf "zerotier-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      zerotier:
        zerotier:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
