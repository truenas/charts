{{/*
Ensure a database is configured when using Geo
listen over TLS */}}
{{- define "gitlab.checkConfig.geo.database" -}}
{{- with $.Values.global -}}
{{- if eq true .geo.enabled -}}
{{-   if not .psql.host }}
geo: no database provided
    It appears Geo was configured but no database was provided. Geo behaviors require external databases. Ensure `global.psql.host` is set.
{{    end -}}
{{-   if not .psql.password.secret }}
geo: no database password provided
    It appears Geo was configured, but no database password was provided. Geo behaviors require external databases. Ensure `global.psql.password.secret` is set.
{{   end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{/* END gitlab.geo.database */}}

{{/*
Ensure a database is configured when using Geo secondary
listen over TLS */}}
{{- define "gitlab.checkConfig.geo.secondary.database" -}}
{{- with $.Values.global.geo -}}
{{- if include "gitlab.geo.secondary" $ }}
{{-   if not .psql.host }}
geo: no secondary database provided
    It appears Geo was configured with `role: secondary`, but no database was provided. Geo behaviors require external databases. Ensure `global.geo.psql.host` is set.
{{    end -}}
{{-   if not .psql.password.secret }}
geo: no secondary database password provided
    It appears Geo was configured with `role: secondary`, but no database password was provided. Geo behaviors require external databases. Ensure `global.geo.psql.password.secret` is set.
{{    end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{/* END gitlab.geo.secondary.database */}}

{{/*
Ensure that when Registry replication is enabled for Geo, a primary API URL is specified.
*/}}
{{- define "gitlab.checkConfig.geo.registry.replication.primaryApiUrl" -}}
{{- if and (eq true .Values.global.geo.enabled) (and (eq .Values.global.geo.role "secondary") (eq true .Values.global.geo.registry.replication.enabled)) -}}
{{-   if not .Values.global.geo.registry.replication.primaryApiUrl }}
geo:
    Registry replication is enabled for GitLab Geo, but no primary API URL is specified. Please specify a value for `global.geo.registry.replication.primaryApiUrl`.
{{-   end -}}
{{- end -}}
{{- end -}}
