{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/ovh.md */}}
{{- define "ddns.config.ovh" -}}
  {{- $item := .item }}
mode: {{ $item.ovhMode | required "DDNS Updater - Expected non-empty [Mode] for OVH provider" }}
{{- if eq $item.ovhMode "dynamic" }}
username: {{ $item.ovhUsername | required "DDNS Updater - Expected non-empty [Username] for OVH provider on [dynamic] mode" }}
password: {{ $item.ovhPassword | required "DDNS Updater - Expected non-empty [Password] for OVH provider on [dynamic] mode" }}
{{- else if eq $item.ovhMode "api" }}
api_endpoint: {{ $item.ovhApiEndpoint | required "DDNS Updater - Expected non-empty [API Endpoint] for OVH provider on [api] mode" }}
app_key: {{ $item.ovhAppKey | required "DDNS Updater - Expected non-empty [App Key] for OVH provider on [api] mode" }}
app_secret: {{ $item.ovhAppSecret | required "DDNS Updater - Expected non-empty [App Secret] for OVH provider on [api] mode"}}
consumer_key: {{ $item.ovhConsumerKey | required "DDNS Updater - Expected non-empty [Consumer Key] for OVH provider on [api] mode" }}
{{- else -}}
  {{- fail (printf "DDNS Updater - Expected [Mode] to be one of [Dynamic, API], but got [%v]" $item.ovhMode) -}}
{{- end }}
provider_ip: {{ $item.ovhProviderIP }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: ovh                     - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      ovhMode: dynamic                  - Required - Valid values (dynami/api)

      # Dynamic Mode
      ovhUsername: username             - Required
      ovhPassword: password             - Required

      # API Mode
      ovhApiEndpoint: endpoint          - Required
      ovhAppKey: appKey                 - Required
      ovhAppSecret: appSecret           - Required
      ovhConsumerKey: consumerKey       - Required

      ovhProviderIP: false              - Required - Valid values (true/false)
*/}}
