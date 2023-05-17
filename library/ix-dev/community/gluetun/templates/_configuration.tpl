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
      {{ $vpnInterface := .Release.Name | replace "-" "" | trunc 15 | lower }}
      {{ if gt (len $vpnInterface) 15 }}
        {{ fail "Gluetun - App name is used also for interface name and cannot exceed 15 characters" }}
      {{ end }}
      VPN_INTERFACE: {{ $vpnInterface }}

      {{/* Include common configuration */}}
      {{- include "gluetun.configs.common.env" $ | nindent 6 }}

      {{/* Include common configuration based on type */}}
      {{- if eq .Values.gluetunConfig.type "openvpn" }}
        {{- include "gluetun.configs.openvpn.env" $ | nindent 6 }}
      {{- else if eq .Values.gluetunConfig.type "wireguard" }}
        {{- include "gluetun.configs.wireguard.env" $ | nindent 6 }}
      {{- end }}

      {{/* Include provider specific validation */}}
      {{- include (printf "gluetun.%v.%v.validation" .Values.gluetunConfig.provider .Values.gluetunConfig.type) $ | nindent 6 }}
{{- end -}}

{{- define "gluetun.openvpn.filemount" -}}
  {{ if eq .Values.gluetunConfig.openvpnCertKeyMethod "file" }}
  openvpn-certificate:
    enabled: true
    type: hostPath
    hostPath: {{ .Values.gluetunConfig.openvpnCertHostPath }}
    hostPathType: File
    targetSelector:
      gluetun:
        gluetun:
          mountPath: /gluetun/client.crt
  openvpn-key:
    enabled: true
    type: hostPath
    hostPath: {{ .Values.gluetunConfig.openvpnKeyHostPath }}
    hostPathType: File
    targetSelector:
      gluetun:
        gluetun:
          mountPath: /gluetun/openvpn_encrypted_key
  {{ end }}
  {{ if eq .Values.gluetunConfig.provider "custom" }}
  custom-conf:
    enabled: true
    type: hostPath
    hostPath: {{ .Values.gluetunConfig.openvpnCustomConfigHostPath }}
    hostPathType: File
    targetSelector:
      gluetun:
        gluetun:
          mountPath: /gluetun/custom.conf
  {{ end }}
{{- end -}}
