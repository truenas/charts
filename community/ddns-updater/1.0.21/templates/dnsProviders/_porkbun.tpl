{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/porkbun.md */}}
{{- define "ddns.config.porkbun" -}}
  {{- $item := .item }}
api_key: {{ $item.porkbunApiKey | required "DDNS Updater - Expected non-empty [API Key] for Porkbun provider" }}
secret_api_key: {{ $item.porkbunSecretApiKey | required "DDNS Updater - Expected non-empty [Secret API Key] for Porkbun provider" }}
{{- if $item.porkbunTtl }}
ttl: {{ $item.porkbunTtl }}
{{- end }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: opendns                 - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      porkbunApiKey: apikey             - Required
      porkbunSecretApiKey: secretapikey - Required
      porkbunTtl: 300                   - Optional
*/}}
