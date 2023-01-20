{{/* ######## Templates related to Geo functionality */}}

{{/*
Return the Geo DB hostname
*/}}
{{- define "gitlab.geo.psql.host" -}}
{{- if .Values.global.geo.psql.host -}}
{{-   .Values.global.geo.psql.host | quote -}}
{{- else -}}
{{-   printf "%s-%s" .Release.Name "geo-postgresql" -}}
{{- end -}}
{{- end -}}

{{/*
Return the Geo database name
*/}}
{{- define "gitlab.geo.psql.database" -}}
{{- coalesce .Values.global.geo.psql.database "gitlabhq_geo_production" | quote -}}
{{- end -}}

{{/*
Return the Geo database username
If the postgresql username is provided, it will use that, otherwise it will fallback
to "gitlab_replicator" default
*/}}
{{- define "gitlab.geo.psql.username" -}}
{{- coalesce .Values.global.geo.psql.username "gitlab_geo" -}}
{{- end -}}

{{/*
Return the Geo database port
If the postgresql port is provided, it will use that, otherwise it will fallback
to 5432 default
*/}}
{{- define "gitlab.geo.psql.port" -}}
{{- coalesce .Values.global.geo.psql.port 5432 -}}
{{- end -}}

{{/*
Return the Geo database secret name
Defaults to a release-based name and falls back to .Values.global.geo.psql.secretName
  when using an external postegresql
*/}}
{{- define "gitlab.geo.psql.password.secret" -}}
{{- default (printf "%s-%s" .Release.Name "geo-postgresql-password") .Values.global.geo.psql.password.secret | quote -}}
{{- end -}}

{{/* NOTE: SKIPPED `postgresql.secretName` */}}

{{/*
Return the name of the key in a secret that contains the postgres password
Uses `postgresql-password` to match upstream postgresql chart when not using an
  external postegresql
*/}}
{{- define "gitlab.geo.psql.password.key" -}}
{{- default "postgresql-password" .Values.global.geo.psql.password.key | quote -}}
{{- end -}}
