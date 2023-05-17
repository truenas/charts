{{/* https://github.com/qdm12/gluetun/wiki/Surfshark */}}
{{- define "gluetun.surfshark.openvpn.validation" -}}
  {{- $req := (list "openvpnUser" "openvpnPassword") -}}

  {{- $unsup := (list "serverNames") -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
  {{- include "gluetun.unsupported.server.options" (dict "rootCtx" $ "options" $unsup) -}}
{{- end -}}

{{- define "gluetun.surfshark.wireguard.validation" -}}
  {{- $req := (list "wireguardPrivateKey" "wireguardAddresses") -}}

  {{- $unsup := (list "serverNames") -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
  {{- include "gluetun.unsupported.server.options" (dict "rootCtx" $ "options" $unsup) -}}
{{- end -}}
