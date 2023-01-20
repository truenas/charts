{{/*
Ensure the provided global.appConfig.maxRequestDurationSeconds value is smaller than
webservice's worker timeout */}}
{{- define "gitlab.checkConfig.appConfig.maxRequestDurationSeconds" -}}
{{- $maxDuration := $.Values.global.appConfig.maxRequestDurationSeconds }}
{{- if $maxDuration }}
{{- $workerTimeout := $.Values.global.webservice.workerTimeout }}
{{- if not (lt $maxDuration $workerTimeout) }}
gitlab: maxRequestDurationSeconds should be smaller than Webservice's worker timeout
        The current value of global.appConfig.maxRequestDurationSeconds ({{ $maxDuration }}) is greater than or equal to global.webservice.workerTimeout ({{ $workerTimeout }}) while it should be a lesser value.
{{- end }}
{{- end }}
{{- end }}
{{/* END gitlab.checkConfig.appConfig.maxRequestDurationSeconds */}}

{{/*
Ensure terminationGracePeriodSeconds is longer than blackoutSeconds
*/}}
{{- define "gitlab.checkConfig.webservice.gracePeriod" -}}
{{-   $terminationGracePeriodSeconds := default 30 .Values.gitlab.webservice.deployment.terminationGracePeriodSeconds | int -}}
{{-   $blackoutSeconds := .Values.gitlab.webservice.shutdown.blackoutSeconds | int -}}
{{- if lt $terminationGracePeriodSeconds $blackoutSeconds }}
You must set terminationGracePeriodSeconds ({{ $terminationGracePeriodSeconds }}) longer than blackoutSeconds ({{ $blackoutSeconds }})
{{  end -}}
{{- end -}}
{{/* END gitlab.checkConfig.webservice.gracePeriod */}}

{{/*
Ensure that when type is set to LoadBalancer that loadBalancerSourceRanges are set
*/}}
{{- define "gitlab.checkConfig.webservice.loadBalancer" -}}
{{-   if .Values.gitlab.webservice.enabled -}}
{{-     $serviceType := .Values.gitlab.webservice.service.type -}}
{{-     $numDeployments := len .Values.gitlab.webservice.deployments -}}
{{-     if (and (eq $serviceType "LoadBalancer") (gt $numDeployments 1)) }}
webservice:
    It is not currently recommended to set a service type of `LoadBalancer` with multiple deployments defined.
    Instead, use a global `service.type` of `ClusterIP` and override `service.type` in each deployment.
{{-     end -}}
{{-     range $name, $deployment := .Values.gitlab.webservice.deployments -}}
{{-     $serviceType := $deployment.service.type -}}
{{-     $loadBalancerSourceRanges := $deployment.service.loadBalancerSourceRanges -}}
{{-       if (and (eq $serviceType "LoadBalancer") (empty ($loadBalancerSourceRanges))) }}
webservice:
    It is not currently recommended to set a service type of `{{ $serviceType }}` on a public exposed network without restrictions, please add `service.loadBalancerSourceRanges` to limit access to the service of the `{{ $name }}` deployment.
{{-       end -}}
{{-     end -}}
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.webservice.loadBalancer */}}
