{{- define "gluetun.configuration" -}}
{{- include "gluetun.validation" $ }}
configmap:
  gluetun:
    enabled: true
    data:
      VPN_SERVICE_PROVIDER: {{ .Values.gluetunConfig.provider }}
      VPN_TYPE: {{ .Values.gluetunConfig.type }}

      {{/* Include common configuration */}}
      {{- include "gluetun.configs.common.env" $ | nindent 6 }}

      {{/* Include common configuration based on type */}}
      {{- if eq .Values.gluetunConfig.type "openvpn" }}
        {{- include "gluetun.configs.openvpn.env" $ }}
      {{- else if eq .Values.gluetunConfig.type "wireguard" }}
        {{- include "gluetun.configs.wireguard.env" $ }}
      {{- end }}

      {{/* Include provider specific configuration */}}
      {{- include (printf "gluetun.%v.%v.env" .Values.gluetunConfig.provider .Values.gluetunConfig.type) $ | nindent 6 }}
{{- end -}}
