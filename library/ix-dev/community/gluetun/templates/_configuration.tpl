{{- define "gluetun.configuration" -}}
{{- include "gluetun.validation" $ }}
configmap:
  gluetun:
    enabled: true
    data:
      VPN_SERVICE_PROVIDER: {{ .Values.gluetunConfig.provider }}
      VPN_TYPE: {{ .Values.gluetunConfig.type }}
      PUBLICIP_FILE: /tmp/gluetun/ip
      {{/* Make VPN interface unique for each app instance */}}
      VPN_INTERFACE: {{ printf "%vtun0" .Release.Name }}

      {{/* Include common configuration */}}
      {{- include "gluetun.configs.common.env" $ | nindent 6 }}

      {{/* Include common configuration based on type */}}
      {{- if eq .Values.gluetunConfig.type "openvpn" }}
        {{- include "gluetun.configs.openvpn.env" $ | nindent 6 }}
      {{- else if eq .Values.gluetunConfig.type "wireguard" }}
        {{- include "gluetun.configs.wireguard.env" $ | nindent 6 }}
      {{- end }}

      {{/* Include provider specific configuration */}}
      {{- include (printf "gluetun.%v.%v.validation" .Values.gluetunConfig.provider .Values.gluetunConfig.type) $ | nindent 6 }}
{{- end -}}
