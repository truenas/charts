{{/* https://github.com/qdm12/gluetun/wiki/IVPN */}}
{{- define "gluetun.ivpn.openvpn.validation" -}}
  {{- $req := (list "openvpnUser") -}}

  {{- $unsup := (list "serverRegions" "serverNames") -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
  {{- include "gluetun.unsupported.server.options" (dict "rootCtx" $ "options" $unsup) -}}
{{- end -}}

{{- define "gluetun.ivpn.wireguard.validation" -}}
  {{- $req := (list "wireguardPrivateKey" "wireguardAddresses") -}}

  {{- $unsup := (list "serverRegions" "serverNames") -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
  {{- include "gluetun.unsupported.server.options" (dict "rootCtx" $ "options" $unsup) -}}
{{- end -}}
