{{- define "ddns.configuration" -}}
{{- include "ddns.validation" $ }}

configmap:
  ddns-config:
    enabled: true
    data:
      PERIOD: {{ .Values.ddnsConfig.period | quote }}
      HTTP_TIMEOUT: {{ .Values.ddnsConfig.httpTimeout | quote }}
      BACKUP_PERIOD: {{ .Values.ddnsConfig.backupPeriod | quote }}
      UPDATE_COOLDOWN_PERIOD: {{ .Values.ddnsConfig.updateCooldownPeriod | quote }}
      PUBLICIP_DNS_TIMEOUT: {{ .Values.ddnsConfig.publicIpDnsTimeout | quote }}
      PUBLICIP_DNS_PROVIDERS: {{ include "ddns.getProviders" (dict "providerList" .Values.ddnsConfig.publicIpDnsProviders) }}
      PUBLICIP_HTTP_PROVIDERS: {{ include "ddns.getProviders" (dict "providerList" .Values.ddnsConfig.publicIpHttpProviders) }}
      PUBLICIPV4_HTTP_PROVIDERS: {{ include "ddns.getProviders" (dict "providerList" .Values.ddnsConfig.publicIpv4HttpProviders) }}
      PUBLICIPV6_HTTP_PROVIDERS: {{ include "ddns.getProviders" (dict "providerList" .Values.ddnsConfig.publicIpv6HttpProviders) }}
      PUBLICIP_FETCHERS: {{ include "ddns.getProviders" (dict "providerList" .Values.ddnsConfig.publicIpFetchers) }}
{{- end -}}

{{- define "ddns.validation" -}}

  {{- include "ddns.validateDictsList" (dict "text" "Public IP DNS Providers"
                                            "list" .Values.ddnsConfig.publicIpDnsProviders
                                            "valid" (list "all" "cloudflare" "google")) -}}

  {{- include "ddns.validateDictsList" (dict "text" "Public IP HTTP Providers"
                                            "list" .Values.ddnsConfig.publicIpHttpProviders
                                            "valid" (list "all" "custom" "opendns" "ifconfig" "ipinfo" "ddnss" "google")) -}}

  {{- include "ddns.validateDictsList" (dict "text" "Public IPv4 HTTP Providers"
                                            "list" .Values.ddnsConfig.publicIpv4HttpProviders
                                            "valid" (list "all" "custom" "ipify" "noip")) -}}

  {{- include "ddns.validateDictsList" (dict "text" "Public IPv6 HTTP Providers"
                                            "list" .Values.ddnsConfig.publicIpv6HttpProviders
                                            "valid" (list "all" "custom" "ipify" "noip")) -}}

  {{- include "ddns.validateDictsList" (dict "text" "Public IP Fetchers"
                                            "list" .Values.ddnsConfig.publicIpFetchers
                                            "valid" (list "all" "http" "dns")) -}}
{{- end -}}

{{- define "ddns.validateDictsList" -}}
  {{- $text := .text -}}
  {{- $list := .list -}}
  {{- $valid := .valid -}}
  {{- $type := .type -}}

  {{- if not $list -}}
    {{- fail (printf "DDNS Updater - Expected non-empty [%v]" $text) -}}
  {{- end -}}

  {{- range $list -}}
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

{{- define "ddns.getProviders" -}}
  {{- $providerList := .providerList -}}
  {{- $return := list -}}

  {{- range $providerList -}}
    {{- if eq .provider "custom" -}}
      {{- $return = append $return .custom -}}
    {{- else -}}
      {{- $return = append $return .provider -}}
    {{- end -}}
  {{- end -}}

  {{- join "," $return -}}
{{- end -}}
