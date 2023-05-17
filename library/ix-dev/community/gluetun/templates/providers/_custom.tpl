{{/* https://github.com/qdm12/gluetun/wiki/Custom-provider */}}
{{- define "gluetun.custom.openvpn.validation" -}}
  {{- $req := (list "openvpnCustomConfigHostPath") -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
{{- end -}}

{{- define "gluetun.custom.wireguard.validation" -}}
  {{- $req := (list "wireguardPrivateKey" "wireguardPublicKey" "wireguardPrivateKey") -}}

  {{- include "gluetun.options.required" (dict "rootCtx" $ "options" $req) -}}
{{- end -}}
