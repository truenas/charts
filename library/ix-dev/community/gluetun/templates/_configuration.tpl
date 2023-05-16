{{- define "gluetun.configuration" -}}
{{- include "gluetun.validation" $ }}
configmap:
  gluetun:
    enabled: true
    data:
      VPN_SERVICE_PROVIDER: {{ .Values.gluetunConfig.provider }}
      VPN_TYPE: {{ .Values.gluetunConfig.type }}

      {{- include (printf "gluetun.%v.%v.env" .Values.gluetunConfig.provider .Values.gluetunConfig.type) $ | nindent 6 }}
      {{- include "gluetun.configs.common.env" $ | nindent 6 }}

      {{- if eq .Values.gluetunConfig.type "openvpn" }}
        {{- with .Values.gluetunConfig.openvpnUser }}
      OPENVPN_USER: {{ . }}
        {{- end }}
        {{- with .Values.gluetunConfig.openvpnPassword }}
      OPENVPN_PASSWORD: {{ . }}
        {{- end }}
      {{- else if eq .Values.gluetunConfig.type "wireguard" }}

      {{- end }}
{{- end -}}
