{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/hetzner.md */}}
{{- define "ddns.config.hetzner" -}}
  {{- $item := .item }}
token: {{ $item.hetznerToken | required "DDNS Updater - Expected non-empty [Token] for Hetzner provider" }}
zone_identifier: {{ $item.hetznerZoneIdentifier | required "DDNS Updater - Expected non-empty [Zone Identifier] for Hetzner provider" }}
ttl: {{ $item.hetznerTtl }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: hetzner             - Required
      domain: "example.com"         - Required
      host: "@"                     - Required - Valid value ("@" or subdomain)
      ipVersion: ""                 - Required - Valid values (ipv4/ipv6/"")
      hetznerToken: pass            - Required
      hetznerZoneIdentifier: someid - Required
      hetznerTtl: 60                - Optional
*/}}
