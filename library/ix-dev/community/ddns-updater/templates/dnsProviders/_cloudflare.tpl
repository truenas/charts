{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/cloudflare.md */}}
{{- define "ddns.config.cloudflare" -}}
  {{- $item := .item }}
zone_identifier: {{ $item.cfZoneID | required "DDNS Updater - Expected non-empty [Zone Identifier] for Cloudflare provider" }}
ttl: {{ $item.cfTtl | required "DDNS Updater - Expected non-empty [TTL] for Cloudflare provider" }}
proxied: {{ $item.cfProxied | default false }}
{{- if $item.cfToken }}
token: {{ $item.cfToken }}
{{- else if $item.cfUserServiceKey }}
user_service_key: {{ $item.cfUserServiceKey }}
{{- else if and $item.cfEmail $item.cfApiKey }}
email: {{ $item.cfEmail }}
api_key: {{ $item.cfApiKey }}
{{- else -}}
  {{- fail "DDNS Updater - Cloudflare provider requires either [Token] or [User Service Key] or [Email and API Key]" -}}
{{- end -}}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: cloudflare      - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@")
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      cfZoneID: id              - Required
      cfTtl: 1                  - Required - Valid values (>=1)
      cfProxied: false          - Required - Valid values (true/false)

      # One of the following is required
      # Token
      cfToken: token

      # User service key
      cfUserServiceKey: user_service_key

      # Email and API key
      cfEmail: email
      cfApiKey: api_key
*/}}
