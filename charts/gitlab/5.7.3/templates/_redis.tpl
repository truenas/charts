{{/* ######### Redis related templates */}}

{{/*
Build a dict of redis configuration

- inherit from global.redis, all but sentinels
- use values within children, if they exist, even if "empty"
*/}}
{{- define "gitlab.redis.configMerge" -}}
{{- $_ := set $ "redisConfigName" (default "" $.redisConfigName) -}}
{{-     $_ := unset $ "redisMergedConfig" -}}
{{-     $_ := set $ "redisMergedConfig" (dict "redisConfigName" $.redisConfigName) -}}
{{-     range $want := list "host" "port" "password" "scheme" -}}
{{-       $_ := set $.redisMergedConfig $want (pluck $want (index $.Values.global.redis $.redisConfigName) $.Values.global.redis | first) -}}
{{-     end -}}
{{-     range $key := keys $.Values.global.redis.password -}}
{{-       if not (hasKey $.redisMergedConfig.password $key) -}}
{{-         $_ := set $.redisMergedConfig.password $key (index $.Values.global.redis.password $key) -}}
{{-       end -}}
{{-     end -}}
{{- end -}}

{{/*
Return the redis password secret name
*/}}
{{- define "gitlab.redis.password.secret" -}}
{{- include "gitlab.redis.configMerge" . -}}
{{- default (printf "%s-redis-secret" .Release.Name) .redisMergedConfig.password.secret | quote -}}
{{- end -}}

{{/*
Return the redis password secret key
*/}}
{{- define "gitlab.redis.password.key" -}}
{{- include "gitlab.redis.configMerge" . -}}
{{- default "secret" .redisMergedConfig.password.key | quote -}}
{{- end -}}
