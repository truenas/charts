{{/*
Ensure that `postgresql.image.tag` meets current requirements
*/}}
{{- define "gitlab.checkConfig.postgresql.deprecatedVersion" -}}
{{-   $imageTag := .Values.postgresql.image.tag -}}
{{-   $majorVersion := (split "." (split "-" ($imageTag | toString))._0)._0 | int -}}
{{-   if or (eq $majorVersion 0) (lt $majorVersion 12) -}}
postgresql:
  Image tag is "{{ $imageTag }}".
{{-     if (eq $majorVersion 0) }}
  Image tag is malformed. It should begin with the numeric major version.
{{-     else if (lt $majorVersion 12) }}
  PostgreSQL 11 and earlier is not supported in GitLab 14. The minimum required version is PostgreSQL 12.
{{-     end -}}
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.postgresql.deprecatedVersion */}}


{{/*
Ensure that if `psql.password.useSecret` is set to false, a path to the password file is provided
*/}}
{{- define "gitlab.checkConfig.postgresql.noPasswordFile" -}}
{{- $errorMsg := list -}}
{{- $subcharts := pick .Values.gitlab "geo-logcursor" "gitlab-exporter" "migrations" "sidekiq" "toolbox" "webservice" -}}
{{- range $name, $sub := $subcharts -}}
{{-   $useSecret := include "gitlab.boolean.local" (dict "local" (pluck "useSecret" (index $sub "psql" "password") | first) "global" $.Values.global.psql.password.useSecret "default" true) -}}
{{-   if and (not $useSecret) (not (pluck "file" (index $sub "psql" "password") ($.Values.global.psql.password) | first)) -}}
{{-      $errorMsg = append $errorMsg (printf "%s: If `psql.password.useSecret` is set to false, you must specify a value for `psql.password.file`." $name) -}}
{{-   end -}}
{{-   if and (not $useSecret) ($.Values.postgresql.install) -}}
{{-      $errorMsg = append $errorMsg (printf "%s: PostgreSQL can not be deployed with this chart when using `psql.password.useSecret` is false." $name) -}}
{{-   end -}}
{{- end -}}
{{- if not (empty $errorMsg) }}
postgresql:
{{- range $msg := $errorMsg }}
    {{ $msg }}
{{- end }}
    This configuration is not supported.
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.postgresql.noPasswordFile */}}

{{/*
Ensure that `postgresql.install: false` when `global.psql.load_balancing` defined
*/}}
{{- define "gitlab.checkConfig.database.externalLoadBalancing" -}}
{{- if hasKey .Values.global.psql "load_balancing" -}}
{{-   with .Values.global.psql.load_balancing -}}
{{-     if and $.Values.postgresql.install (kindIs "map" .) }}
postgresql:
    It appears PostgreSQL is set to install, but database load balancing is also enabled. This configuration is not supported.
    See https://docs.gitlab.com/charts/charts/globals#configure-postgresql-settings
{{-     end -}}
{{-     if not (kindIs "map" .) }}
postgresql:
    It appears database load balancing is desired, but the current configuration is not supported.
    See https://docs.gitlab.com/charts/charts/globals#configure-postgresql-settings
{{-     end -}}
{{-     if and (not (hasKey . "discover") ) (not (hasKey . "hosts") ) }}
postgresql:
    It appears database load balancing is desired, but the current configuration is not supported.
    You must specify `load_balancing.hosts` or `load_balancing.discover`.
    See https://docs.gitlab.com/charts/charts/globals#configure-postgresql-settings
{{-     end -}}
{{-     if and (hasKey . "hosts") (not (kindIs "slice" .hosts) ) }}
postgresql:
    Database load balancing using `hosts` is configured, but does not appear to be a list.
    See https://docs.gitlab.com/charts/charts/globals#configure-postgresql-settings
    Current format: {{ kindOf .hosts }}
{{-     end -}}
{{-     if and (hasKey . "discover") (not (kindIs "map" .discover)) }}
postgresql:
    Database load balancing using `discover` is configured, but does not appear to be a map.
    See https://docs.gitlab.com/charts/charts/globals#configure-postgresql-settings
    Current format: {{ kindOf .discover }}
{{-     end -}}
{{-   end -}}
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.database.externalLoadBalancing */}}
