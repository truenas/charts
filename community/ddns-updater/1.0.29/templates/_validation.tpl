{{- define "ddns.validation" -}}
  {{- include "ddns.validatePublicIpProviders" (dict "text" "Public IP DNS Providers"
                                            "list" .Values.ddnsConfig.publicIpDnsProviders
                                            "valid" (list "all" "cloudflare" "google")) -}}

  {{- include "ddns.validatePublicIpProviders" (dict "text" "Public IP HTTP Providers"
                                            "list" .Values.ddnsConfig.publicIpHttpProviders
                                            "valid" (list "all" "custom" "opendns" "ifconfig" "ipinfo" "ddnss" "google")) -}}

  {{- include "ddns.validatePublicIpProviders" (dict "text" "Public IPv4 HTTP Providers"
                                            "list" .Values.ddnsConfig.publicIpv4HttpProviders
                                            "valid" (list "all" "custom" "ipify" "noip")) -}}

  {{- include "ddns.validatePublicIpProviders" (dict "text" "Public IPv6 HTTP Providers"
                                            "list" .Values.ddnsConfig.publicIpv6HttpProviders
                                            "valid" (list "all" "custom" "ipify" "noip")) -}}

  {{- include "ddns.validatePublicIpProviders" (dict "text" "Public IP Fetchers"
                                            "list" .Values.ddnsConfig.publicIpFetchers
                                            "valid" (list "all" "http" "dns")) -}}
{{- end -}}

{{- define "ddns.validatePublicIpProviders" -}}
  {{- $text := .text -}}
  {{- $list := .list -}}
  {{- $valid := .valid -}}
  {{- $type := .type -}}

  {{- if not $list -}}
    {{- fail (printf "DDNS Updater - Expected non-empty [%v]" $text) -}}
  {{- end -}}

  {{- $userProviders := list -}}
  {{- range $list -}}
    {{- if mustHas .provider $userProviders -}}
      {{- fail (printf "DDNS Updater - Expected unique values in [%v], but got [%v] more than once" $text .provider) -}}
    {{- end -}}
    {{- $userProviders = mustAppend $userProviders .provider -}}

    {{- if not (mustHas .provider $valid) -}}
      {{- fail (printf "DDNS Updater - [%v] valid values are [%v], but got [%v]" $text (join ", " $valid) .provider) -}}
    {{- end -}}

    {{- if eq .provider "all" -}}
      {{- if ne (len $list) 1 -}}
        {{- fail (printf "DDNS Updater - [%v] cannot contain other values when [all] is selected" $text) -}}
      {{- end -}}
    {{- end -}}

    {{- if eq .provider "custom" -}}
      {{- if not .custom -}}
        {{- fail (printf "DDNS Updater - [%v] expected non-empty [Custom Value]" $text) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
