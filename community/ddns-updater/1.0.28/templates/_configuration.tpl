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
      SHOUTRRR_ADDRESSES: {{ join "," .Values.ddnsConfig.shoutrrrAddresses | quote }}
      PUBLICIP_DNS_TIMEOUT: {{ .Values.ddnsConfig.publicIpDnsTimeout | quote }}
      PUBLICIP_DNS_PROVIDERS: {{ include "ddns.getPublicIpProviders" (dict "providerList" .Values.ddnsConfig.publicIpDnsProviders) }}
      PUBLICIP_HTTP_PROVIDERS: {{ include "ddns.getPublicIpProviders" (dict "providerList" .Values.ddnsConfig.publicIpHttpProviders) }}
      PUBLICIPV4_HTTP_PROVIDERS: {{ include "ddns.getPublicIpProviders" (dict "providerList" .Values.ddnsConfig.publicIpv4HttpProviders) }}
      PUBLICIPV6_HTTP_PROVIDERS: {{ include "ddns.getPublicIpProviders" (dict "providerList" .Values.ddnsConfig.publicIpv6HttpProviders) }}
      PUBLICIP_FETCHERS: {{ include "ddns.getPublicIpProviders" (dict "providerList" .Values.ddnsConfig.publicIpFetchers) }}
      {{ $config := include "ddns.generateConfig" $ | fromYaml }}
      CONFIG: {{ $config | toJson | quote }}
{{- end -}}

{{- define "ddns.getPublicIpProviders" -}}
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

{{/* Generates configuration in yaml
    and then it gets converted to single line
    JSON and passed as an env variable
*/}}
{{- define "ddns.generateConfig" -}}
{{- if not .Values.ddnsConfig.config -}}
  {{- fail "DDNS Updater - Expected at least 1 item in DNS Provider COnfiguration" -}}
{{- end -}}
{{- $providers := (list "aliyun" "allinkl" "cloudflare" "dd24" "ddnss" "digitalocean"
                        "dnsomatic" "dnspod" "dondominio" "dreamhost" "duckdns" "dyn"
                        "dynu" "dynv6" "freedns" "gandi" "gcp" "godaddy" "google" "he"
                        "infomaniak" "inwx" "linode" "luadns" "namecheap" "njalla" "noip"
                        "opendns" "ovh" "porkbun" "selfhost.de" "servercow" "spdyn"
                        "strato" "variomedia" "ionos" "desec" "easydns" "goip" "hetzner"
                        "name.com" "netcup" "nowdns" "zoneedit") }}
settings:
  {{- range $item := .Values.ddnsConfig.config -}}
    {{- if not (mustHas $item.provider $providers) -}}
      {{- fail (printf "DDNS Updater - DNS Provider [%v] is not supported" $item.provider) -}}
    {{- end }}
  - provider: {{ $item.provider }}
    host: {{ $item.host | required (printf "DDNS Updater - Expected non-empty [Host] for %v provider" $item.provider) | quote }}
    domain: {{ $item.domain | required (printf "DDNS Updater - Expected non-empty [Domain] for %v provider" $item.provider) | quote }}
    ip_version: {{ $item.ipVersion | default "" | quote }}
    {{- include (printf "ddns.config.%v" $item.provider) (dict "item" $item) | trim | nindent 4 -}}
  {{- end -}}
{{- end -}}

{{/* TODO: OVH */}}
