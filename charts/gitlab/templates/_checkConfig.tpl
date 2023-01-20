{{/*
Template for checking configuration

The messages templated here will be combined into a single `fail` call. This creates a means for the user to receive all messages at one time, instead of a frustrating iterative approach.

- Pick a location for the new check.
  + Checks of a group reside in a sub file, `_checkConfig_xxx.tpl`.
  + If there isn't a group for that check yet, put it at the end of this file
  + If there are more than 1 check of a same group, extract those checks into a new
  file following the above format. Don't forget to extract the tests too.
- `define` a new template, prefixed `gitlab.checkConfig.`
- Check for known problems in configuration, and directly output messages (see message format below)
- Add a line to `gitlab.checkConfig` to include the new template.
- Add tests for the newly created check.
  + Tests for checks of a group are put in `spec/integration/check_config/xxx_spec.rb`
  + Tests for other miscellaneous checks are put in `spec/integration/check_config_spec.rb`

Message format:

**NOTE**: The `if` statement preceding the block should _not_ trim the following newline (`}}` not `-}}`), to ensure formatting during output.

```
chart:
    MESSAGE
```
*/}}
{{/*
Compile all warnings into a single message, and call fail.

Due to gotpl scoping, we can't make use of `range`, so we have to add action lines.
*/}}
{{- define "gitlab.checkConfig" -}}
{{- $messages := list -}}
{{/* add templates here */}}

{{/* _checkConfig_mailroom.tpl*/}}
{{- $messages = append $messages (include "gitlab.checkConfig.incomingEmail.microsoftGraph" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.serviceDesk" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.serviceDesk.microsoftGraph" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.incomingEmail.deliveryMethod" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.serviceDeskEmail.deliveryMethod" .) -}}

{{/* _checkConfig_geo.tpl*/}}
{{- $messages = append $messages (include "gitlab.checkConfig.geo.database" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.geo.secondary.database" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.geo.registry.replication.primaryApiUrl" .) -}}

{{/* _checkConfig_gitaly.tpl*/}}
{{- $messages = append $messages (include "gitlab.checkConfig.gitaly.storageNames" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.gitaly.tls" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.gitaly.extern.repos" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.praefect.storageNames" .) -}}

{{/* _checkConfig_nginx.tpl*/}}
{{- $messages = append $messages (include "gitlab.checkConfig.nginx.controller.extraArgs" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.nginx.clusterrole.scope" .) -}}

{{/* _checkConfig_object_storage.tpl*/}}
{{- $messages = append $messages (include "gitlab.checkConfig.objectStorage.consolidatedConfig" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.objectStorage.typeSpecificConfig" .) -}}

{{/* _checkConfig_postgresql.tpl*/}}
{{- $messages = append $messages (include "gitlab.checkConfig.postgresql.deprecatedVersion" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.postgresql.noPasswordFile" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.database.externalLoadBalancing" .) -}}

{{/* _checkConfig_registry.tpl*/}}
{{- $messages = append $messages (include "gitlab.checkConfig.registry.sentry.dsn" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.registry.notifications" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.registry.database" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.registry.gc" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.registry.migration" .) -}}

{{/* _checkConfig_sidekiq.tpl*/}}
{{- $messages = append $messages (include "gitlab.checkConfig.sidekiq.queues.mixed" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.sidekiq.queues" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.sidekiq.timeout" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.sidekiq.routingRules" .) -}}

{{/* _checkConfig_toolbox.tpl*/}}
{{- $messages = append $messages (include "gitlab.toolbox.replicas" .) -}}
{{- $messages = append $messages (include "gitlab.toolbox.backups.objectStorage.config.secret" .) -}}

{{/* _checkConfig_webservice.tpl*/}}
{{- $messages = append $messages (include "gitlab.checkConfig.appConfig.maxRequestDurationSeconds" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.webservice.gracePeriod" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.webservice.loadBalancer" .) -}}

{{/* other checks */}}
{{- $messages = append $messages (include "gitlab.checkConfig.contentSecurityPolicy" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.multipleRedis" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.hostWhenNoInstall" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.sentry" .) -}}
{{- $messages = append $messages (include "gitlab.checkConfig.smtp.openssl_verify_mode" .) -}}
{{- /* prepare output */}}
{{- $messages = without $messages "" -}}
{{- $message := join "\n" $messages -}}

{{- /* print output */}}
{{- if $message -}}
{{-   printf "\nCONFIGURATION CHECKS:\n%s" $message | fail -}}
{{- end -}}
{{- end -}}

{{/*
Ensure that content_security_policy.directives is not empty
*/}}
{{- define "gitlab.checkConfig.contentSecurityPolicy" -}}
{{-   if eq true $.Values.global.appConfig.contentSecurityPolicy.enabled }}
{{-     if not (hasKey $.Values.global.appConfig.contentSecurityPolicy "directives") }}
contentSecurityPolicy:
    When configuring Content Security Policy, you must also configure its Directives.
    set `global.appConfig.contentSecurityPolicy.directives`
    See https://docs.gitlab.com/charts/charts/globals#content-security-policy
{{-   end -}}
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.contentSecurityPolicy */}}

{{/*
Ensure that `redis.install: false` if configuring multiple Redis instances
*/}}
{{- define "gitlab.checkConfig.multipleRedis" -}}
{{/* "cache" "sharedState" "queues" "actioncable" */}}
{{- $x := dict "count" 0 -}}
{{- range $redis := list "cache" "sharedState" "queues" "actioncable" -}}
{{-   if hasKey $.Values.global.redis $redis -}}
{{-     $_ := set $x "count" ( add1 $x.count ) -}}
{{-    end -}}
{{- end -}}
{{- if and .Values.redis.install ( lt 0 $x.count ) }}
redis:
  If configuring multiple Redis servers, you can not use the in-chart Redis server. Please see https://docs.gitlab.com/charts/charts/globals#configure-redis-settings
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.multipleRedis */}}

{{/*
Ensure that `global.redis.host: <hostname>` is present if `redis.install: false`
*/}}
{{- define "gitlab.checkConfig.hostWhenNoInstall" -}}
{{-   if and (not .Values.redis.install) (not .Values.global.redis.host) }}
redis:
  You've disabled the installation of Redis. When using an external Redis, you must populate `global.redis.host`. Please see https://docs.gitlab.com/charts/advanced/external-redis/
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.hostWhenNoInstall */}}

{{/*
Ensure that sentry has a DSN configured if enabled
*/}}
{{- define "gitlab.checkConfig.sentry" -}}
{{-   if $.Values.global.appConfig.sentry.enabled }}
{{-     if (not (or $.Values.global.appConfig.sentry.dsn $.Values.global.appConfig.sentry.clientside_dsn)) }}
sentry:
    When enabling sentry, you must configure at least one DSN.
    See https://docs.gitlab.com/charts/charts/globals.html#sentry-settings
{{-     end -}}
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.sentry */}}

{{/*
Ensure that a correct value is provided for
`global.smtp.openssl_verify_mode`.
*/}}
{{- define "gitlab.checkConfig.smtp.openssl_verify_mode" -}}
{{-   $opensslVerifyModes := list "none" "peer" "client_once" "fail_if_no_peer_cert" -}}
{{-   if .Values.global.smtp.openssl_verify_mode -}}
{{-     if not (has .Values.global.smtp.openssl_verify_mode $opensslVerifyModes) }}
smtp:
    "{{ .Values.global.smtp.openssl_verify_mode }}" is not a valid value for `global.smtp.openssl_verify_mode`.
    Valid values are: {{ join ", " $opensslVerifyModes }}.
{{-     end }}
{{-   end }}
{{- end -}}
{{/* END gitlab.checkConfig.smtp.openssl_verify_mode */}}
