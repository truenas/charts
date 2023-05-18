{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/gcp.md */}}
{{- define "ddns.config.gcp" -}}
  {{- $item := .item }}
project: {{ $item.gcpProject | required "DDNS Updater - Expected non-empty [Project] for GCP provider" }}
zone: {{ $item.gcpZone | required "DDNS Updater - Expected non-empty [Zone] for GCP provider" }}
credentials: {{ $item.gcpCredentials | required "DDNS Updater - Expected non-empty [Credentials] for GCP provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: gcp                                       - Required
      domain: "example.com"                               - Required
      host: "@"                                           - Required - Valid value ("@" or subdomain)
      ipVersion: ""                                       - Required - Valid values (ipv4/ipv6/"")
      gcpProject: my-project-id                           - Required
      gcpZone: my-zone                                    - Required
      gcpCredentials: '{"type": "service_account", ...}'  - Required
*/}}
