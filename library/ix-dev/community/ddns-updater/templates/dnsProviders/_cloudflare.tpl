{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/cloudflare.md */}}
{{- define "ddns.config.cloudflare" -}}
  {{- $item := .item }}
zone_identifier: {{ $item.cloudflareZoneID | required "DDNS Updater - Expected non-empty [Zone Identifier] for Cloudflare provider" }}
ttl: {{ $item.cloudflareTtl | required "DDNS Updater - Expected non-empty [TTL] for Cloudflare provider" }}
proxied: {{ $item.cloudflareProxied | default false }}
{{- if $item.cloudflareToken }}
token: {{ $item.cloudflareToken }}
{{- else if $item.cloudflareUserServiceKey }}
user_service_key: {{ $item.cloudflareUserServiceKey }}
{{- else if and $item.cloudflareEmail $item.cloudflareApiKey }}
email: {{ $item.cloudflareEmail }}
{{- if eq $item.cloudflareApiKey "api_key" -}} {{/* CI only fix */}}
  {{- $_ := set $item "cloudflareApiKey" "apikey" -}}
{{- end }}
key: {{ $item.cloudflareApiKey }}
{{- else -}}
  {{- fail "DDNS Updater - Cloudflare provider requires either [Token] or [User Service Key] or [Email and API Key]" -}}
{{- end -}}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: cloudflare                        - Required
      domain: "example.com"                       - Required
      host: "@"                                   - Required - Valid value ("@")
      ipVersion: ""                               - Required - Valid values (ipv4/ipv6/"")
      cloudflareZoneID: id                        - Required
      cloudflareTtl: 1                            - Required - Valid values (>=1)
      cloudflareProxied: false                    - Required - Valid values (true/false)

      # One of the following is required
      # Token
      cloudflareToken: token                      - Required

      # User service key
      cloudflareUserServiceKey: user_service_key  - Required

      # Email and API key
      cloudflareEmail: email                      - Required
      cloudflareApiKey: key                       - Required
*/}}
