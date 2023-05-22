{{- define "gluetun.configuration" -}}
{{- include "gluetun.validation" $ }}
configmap:
  gluetun:
    enabled: true
    data:
      VPN_SERVICE_PROVIDER: {{ .Values.gluetunConfig.provider }}
      VPN_TYPE: {{ .Values.gluetunConfig.type }}
      PUBLICIP_FILE: /tmp/gluetun/ip
      VPN_INTERFACE: gluetun0

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
      {{/* Firewall */}}
      FIREWALL: {{ ternary "on" "off" .Values.gluetunConfig.firewall | quote }}
      {{ if .Values.gluetunConfig.firewall }}
      FIREWALL_OUTBOUND_SUBNETS: {{ join "," .Values.gluetunConfig.firewallOutboundSubnets }}
      {{ end }}
      {{/* DNS */}}
      DOT: {{ ternary "on" "off" .Values.gluetunConfig.dot | quote }}
      DNS_KEEP_NAMESERVER: {{ ternary "on" "off" .Values.gluetunConfig.dnsKeepNameserver | quote }}
      {{ with .Values.gluetunConfig.dnsAddress }}
      DNS_ADDRESS: {{ . }}
      {{ end }}
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
