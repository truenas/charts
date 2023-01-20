{{/* Check configuration of Sidekiq - don't supply queues and negateQueues */}}
{{- define "gitlab.checkConfig.sidekiq.queues.mixed" -}}
{{- if .Values.gitlab.sidekiq.pods -}}
{{-   range $pod := .Values.gitlab.sidekiq.pods -}}
{{-     if and (hasKey $pod "queues") (hasKey $pod "negateQueues") }}
sidekiq: mixed queues
    It appears you've supplied both `queues` and `negateQueues` for the pod definition of `{{ $pod.name }}`. `negateQueues` is not usable if `queues` is provided. Please use only one.
{{-     end -}}
{{-   end -}}
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.sidekiq.queues.mixed */}}

{{/* Check configuration of Sidekiq - queues must be a string */}}
{{- define "gitlab.checkConfig.sidekiq.queues" -}}
{{- if .Values.gitlab.sidekiq.pods -}}
{{-   range $pod := .Values.gitlab.sidekiq.pods -}}
{{-     if and (hasKey $pod "queues") (ne (kindOf $pod.queues) "string") }}
sidekiq:
    The `queues` in pod definition `{{ $pod.name }}` is not a string.
{{-     else if and (hasKey $pod "negateQueues") (ne (kindOf $pod.negateQueues) "string") }}
sidekiq:
    The `negateQueues` in pod definition `{{ $pod.name }}` is not a string.
{{-     end -}}
{{-   end -}}
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.sidekiq.queues */}}

{{/*
Ensure that Sidekiq timeout is less than terminationGracePeriodSeconds
*/}}
{{- define "gitlab.checkConfig.sidekiq.timeout" -}}
{{-   range $i, $pod := $.Values.gitlab.sidekiq.pods -}}
{{-     $activeTimeout := int (default $.Values.gitlab.sidekiq.timeout $pod.timeout) }}
{{-     $activeTerminationGracePeriodSeconds := int (default $.Values.gitlab.sidekiq.deployment.terminationGracePeriodSeconds $pod.terminationGracePeriodSeconds) }}
{{-     if gt $activeTimeout $activeTerminationGracePeriodSeconds }}
sidekiq:
  You must set `terminationGracePeriodSeconds` ({{ $activeTerminationGracePeriodSeconds }}) longer than `timeout` ({{ $activeTimeout }}) for pod `{{ $pod.name }}`.
{{-     end }}
{{-   end }}
{{- end -}}
{{/* END gitlab.checkConfig.sidekiq.timeout */}}

{{/*
Ensure that Sidekiq routingRules configuration is in a valid format
*/}}
{{- define "gitlab.checkConfig.sidekiq.routingRules" -}}
{{- $validRoutingRules := true -}}
{{- with $.Values.global.appConfig.sidekiq.routingRules }}
{{-   if not (kindIs "slice" .) }}
{{-     $validRoutingRules = false }}
{{-   else -}}
{{-     range $rule := . }}
{{-       if (not (kindIs "slice" $rule)) }}
{{-         $validRoutingRules = false }}
{{-       else if (ne (len $rule) 2) }}
{{-         $validRoutingRules = false }}
{{/*      The first item (routing query) must be a string */}}
{{-       else if not (kindIs "string" (index $rule 0)) }}
{{-         $validRoutingRules = false }}
{{/*      The second item (queue name) must be either a string or null */}}
{{-       else if not (or (kindIs "invalid" (index $rule 1)) (kindIs "string" (index $rule 1))) -}}
{{-         $validRoutingRules = false }}
{{-       end -}}
{{-     end -}}
{{-   end -}}
{{- end -}}
{{- if eq false $validRoutingRules }}
sidekiq:
    The Sidekiq's routing rules list must be an ordered array of tuples of query and corresponding queue.
    See https://docs.gitlab.com/charts/charts/globals.html#sidekiq-routing-rules-settings
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.sidekiq.routingRules */}}
