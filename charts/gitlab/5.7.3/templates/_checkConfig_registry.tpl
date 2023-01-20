{{/*
Ensure that registry's sentry has a DSN configured if enabled
*/}}
{{- define "gitlab.checkConfig.registry.sentry.dsn" -}}
{{-   if $.Values.registry.reporting.sentry.enabled }}
{{-     if not $.Values.registry.reporting.sentry.dsn }}
registry:
    When enabling sentry, you must configure at least one DSN.
    See https://docs.gitlab.com/charts/charts/registry#reporting
{{-     end -}}
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.registry.sentry.dsn */}}

{{/*
Ensure Registry notifications settings are in global scope
*/}}
{{- define "gitlab.checkConfig.registry.notifications" }}
{{- if hasKey $.Values.registry "notifications" }}
Registry: Notifications should be defined in the global scope. Use `global.registry.notifications` setting instead of `registry.notifications`.
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.registry.notifications */}}

{{/*
Ensure Registry database is configured properly and dependencies are met
*/}}
{{- define "gitlab.checkConfig.registry.database" -}}
{{-   if $.Values.registry.database.enabled }}
{{-     $validSSLModes := list "require" "disable" "allow" "prefer" "require" "verify-ca" "verify-full" -}}
{{-     if not (has $.Values.registry.database.sslmode $validSSLModes) }}
registry:
    Invalid SSL mode "{{ .Values.registry.database.sslmode }}".
    Valid values are: {{ join ", " $validSSLModes }}.
    See https://docs.gitlab.com/charts/charts/registry#database
{{-     end -}}
{{-     $pgImageTag := .Values.postgresql.image.tag -}}
{{-     $pgMajorVersion := (split "." (split "-" ($pgImageTag | toString))._0)._0 | int -}}
{{-     if lt $pgMajorVersion 12 -}}
registry:
    Invalid PostgreSQL version "{{ $pgImageTag }}".
    PostgreSQL 12 is the minimum required version for the registry database.
    See https://docs.gitlab.com/charts/charts/registry#database
{{-     end -}}
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.registry.database */}}

{{/*
Ensure Registry migration is configured properly and dependencies are met
*/}}
{{- define "gitlab.checkConfig.registry.migration" -}}
{{-   if and $.Values.registry.migration.enabled (not $.Values.registry.database.enabled) }}
registry:
    Enabling migration mode requires the metadata database to be enabled.
    See https://docs.gitlab.com/charts/charts/registry#migration
{{-   end -}}
{{-   if and $.Values.registry.migration.disablemirrorfs (not $.Values.registry.database.enabled) }}
registry:
    Disabling filesystem metadata requires the metadata database to be enabled.
    See https://docs.gitlab.com/charts/charts/registry#migration
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.registry.migration */}}

{{/*
Ensure Registry online garbage collection is configured properly and dependencies are met
*/}}
{{- define "gitlab.checkConfig.registry.gc" -}}
{{-   if not (or $.Values.registry.gc.disabled $.Values.registry.database.enabled) }}
registry:
    Enabling online garbage collection requires the metadata database to be enabled.
    See https://docs.gitlab.com/charts/charts/registry#gc
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.registry.gc */}}
