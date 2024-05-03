{{- define "wgeasy.workload" -}}
workload:
  wgeasy:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.wgNetwork.hostNetwork }}
      containers:
        wgeasy:
          enabled: true
          primary: true
          imageSelector: image
          {{/* https://github.com/WeeJeWel/wg-easy/pull/394 */}}
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - NET_ADMIN
                - NET_RAW
                - SYS_MODULE
          env:
            WG_PORT: {{ .Values.wgConfig.externalPort }}
            WG_PATH: /etc/wireguard
            PORT: {{ .Values.wgNetwork.webPort }}
            WG_HOST: {{ .Values.wgConfig.host | quote }}
            PASSWORD: {{ .Values.wgConfig.password | quote }}
            WG_PERSISTENT_KEEPALIVE: {{ .Values.wgConfig.keepAlive }}
            WG_MTU: {{ .Values.wgConfig.clientMTU }}
            WG_DEFAULT_ADDRESS: {{ .Values.wgConfig.clientAddressRange }}
            WG_DEFAULT_DNS: {{ .Values.wgConfig.clientDNSServer }}
            WG_DEVICE: {{ .Values.wgConfig.deviceName | default "eth0" }}
            WG_ALLOWED_IPS: {{ join "," .Values.wgConfig.allowedIPs | default "0.0.0.0/0,::/0" | quote }}
          fixedEnv:
            PUID: 0
          {{ with .Values.wgConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: {{ .Values.wgNetwork.webPort }}
              path: /
            readiness:
              enabled: true
              type: http
              port: {{ .Values.wgNetwork.webPort }}
              path: /
            startup:
              enabled: true
              type: http
              port: {{ .Values.wgNetwork.webPort }}
              path: /
          {{ $ip := .Values.wgConfig.clientAddressRange | replace "x" "0" }}
          lifecycle:
            preStop:
              type: exec
              command:
                - /bin/bash
                - -c
                - |
                  echo "Deleting routes created by the app..."
                  netmask=$(ip route | grep {{ $ip }})
                  netmask=$(echo $netmask | grep -o -E '/.\d*')
                  netmask=${netmask#/}
                  echo "Matched routes to delete... {{ $ip }}/$netmask"
                  # Don't try to delete routes if steps above didn't grep-ed anything
                  if [ ! "$netmask" == "" ]; then
                    ip route del {{ $ip }}/$netmask || echo "Route deletion failed..."
                  fi
                  echo "Routes deleted..."
                  interface=$(ip a | grep wg0)
                  if [ ! "$interface" == "" ]; then
                    echo "Removing wg0 interface..."
                    ip link delete wg0
                    echo "Removed wg0 interface..."
                  fi
{{- end -}}
