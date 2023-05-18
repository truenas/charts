{{/* https://github.com/qdm12/gluetun/wiki/Windscribe */}}
{{- define "gluetun.windscribe.openvpn.validation" -}}
  {{- $req := (list "openvpnUser" "openvpnPassword") -}}

  {{- $unsup := (list "serverCountries" "serverNames") -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
  {{- include "gluetun.unsupported.server.options" (dict "rootCtx" $ "options" $unsup) -}}
{{- end -}}

{{- define "gluetun.windscribe.wireguard.validation" -}}
  {{- $req := (list "wireguardPrivateKey" "wireguardAddresses") -}}

  {{- $unsup := (list "serverCountries" "serverNames") -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
  {{- include "gluetun.unsupported.server.options" (dict "rootCtx" $ "options" $unsup) -}}
{{- end -}}
