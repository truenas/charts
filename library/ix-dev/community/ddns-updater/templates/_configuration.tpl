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
settings:
  {{- range $item := .Values.ddnsConfig.config }}
  - provider: {{ $item.provider }}
    host: {{ $item.host | required (printf "DDNS Updater - Expected non-empty [Host] for %v provider" $item.provider) | quote }}
    domain: {{ $item.domain | required (printf "DDNS Updater - Expected non-empty [Domain] for %v provider" $item.provider) | quote }}
    ip_version: {{ $item.ipVersion | default "" | quote }}
    {{- if eq $item.provider "cloudflare" -}}
      {{- include "ddns.config.cloudflare" (dict "item" $item) | trim | nindent 4 -}}
    {{- else if eq $item.provider "dd24" -}}
      {{- include "ddns.config.dd24" (dict "item" $item) | trim | nindent 4 -}}
    {{- else -}}
      {{- fail (printf "DDNS Updater - Config Provider [%v] is not supported" $item.provider) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
