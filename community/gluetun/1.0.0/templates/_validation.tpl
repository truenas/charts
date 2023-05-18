{{- define "gluetun.validation" -}}
  {{- $providers := (list "custom" "airvpn" "cyberghost" "expressvpn"
                          "fastestvpn" "hidemyass" "ipvanish" "ivpn"
                          "mullvad" "nordvpn" "perfect privacy" "privado"
                          "private internet access" "privatevpn" "protonvpn"
                          "purevpn" "slickvpn" "surfshark" "torguard" "vpnsecure"
                          "vpn unlimited" "vyprvpn" "wevpn" "windscribe") -}}
  {{- if not (mustHas .Values.gluetunConfig.provider $providers) -}}
    {{- fail (printf "Gluetun - Expected [Provider] to be one of [%v], but got [%v]" (join ", " $providers) .Values.gluetunConfig.provider) -}}
  {{- end -}}

  {{- $types := (list "openvpn" "wireguard") -}}
  {{- if not (mustHas .Values.gluetunConfig.type $types) -}}
    {{- fail (printf "Gluetun - Expected [Type] to be one of [%v], but got [%v]" (join ", " $providers) .Values.gluetunConfig.type) -}}
  {{- end -}}

  {{- $methods := (list "none" "file" "content") -}}
  {{- if not (mustHas .Values.gluetunConfig.openvpnCertKeyMethod $methods) -}}
    {{- fail (printf "Gluetun - Expected [OpenVPN Cert and Key Method] to be one of [%v], but got [%v]" (join ", " $methods) .Values.gluetunConfig.openvpnCertKeyMethod) -}}
  {{- end -}}
{{- end -}}

{{/* Included by providers that require specific options */}}
{{- define "gluetun.options.required" -}}
  {{- $options := .options -}}
  {{- $rootCtx := .rootCtx -}}

  {{- $opts := (list "openvpnCert" "openvpnKey" "openvpnCertHostPath"
                      "openvpnKeyHostPath" "openvpnUser" "openvpnPassword"
                      "openvpnKeyPassphrase" "wireguardPrivateKey"
                      "wireguardPublicKey" "wireguardPresharedKey"
                      "wireguardAddresses" "vpnEndpointIP" "vpnEndpointPort"
                      "openvpnCustomConfigHostPath") -}}
  {{- range $opt := $options -}}
    {{- if not (mustHas $opt $opts) -}} {{/* Dev validation, to avoid typos early */}}
      {{- fail (printf "Gluetun - Bad option (%v) passed in provider [%v]." $opt $rootCtx.Values.gluetunConfig.provider) -}}
    {{- end -}}

    {{- if not (get $rootCtx.Values.gluetunConfig $opt) -}}
      {{- fail (printf "Gluetun - Provider [%v] requires non-empty [%v] option on type [%v]." $rootCtx.Values.gluetunConfig.provider $opt $rootCtx.Values.gluetunConfig.type) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/* Included by providers that do not support one the the 2 types */}}
{{- define "gluetun.unsupported.type" -}}
  {{- fail (printf "Gluetun - Provider [%v] does not support type of [%v]." .Values.gluetunConfig.provider .Values.gluetunConfig.type) -}}
{{- end -}}

{{/* Inluded by providers that do not support all the server options */}}
{{- define "gluetun.unsupported.server.options" -}}
  {{- $options := .options -}}
  {{- $rootCtx := .rootCtx -}}

  {{- $opts := (list "serverRegions" "serverCountries" "serverNames" "serverHostnames" "serverCities") -}}
  {{- range $opt := $options -}}
    {{- if not (mustHas $opt $opts) -}} {{/* Dev validation, to avoid typos early */}}
      {{- fail (printf "Gluetun - Bad option (%v) passed in provider [%v]." $opt $rootCtx.Values.gluetunConfig.provider) -}}
    {{- end -}}

    {{- if (get $rootCtx.Values.gluetunConfig $opt) -}}
      {{- fail (printf "Gluetun - Provider [%v] does not support [%v] option." $rootCtx.Values.gluetunConfig.provider $opt) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "gluetun.certkey.required.error" -}}
  {{- fail (printf "Gluetun - Provider [%v] requires [Key and/or Certificate] either from [File or Content] method on type [openvpn]." .Values.gluetunConfig.provider) -}}
{{- end -}}
