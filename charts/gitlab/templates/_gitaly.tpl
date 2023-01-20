{{/* ######### Gitaly related templates */}}

{{/*
Return the gitaly secret name
Preference is local, global, default (`gitaly-secret`)
*/}}
{{- define "gitlab.gitaly.authToken.secret" -}}
{{- coalesce .Values.global.gitaly.authToken.secret (printf "%s-gitaly-secret" .Release.Name) | quote -}}
{{- end -}}

{{/*
Return the gitaly secret key
Preference is local, global, default (`token`)
*/}}
{{- define "gitlab.gitaly.authToken.key" -}}
{{- coalesce .Values.global.gitaly.authToken.key "token" | quote -}}
{{- end -}}

{{/*
Return the gitaly TLS secret name
*/}}
{{- define "gitlab.gitaly.tls.secret" -}}
{{- default (printf "%s-gitaly-tls" .Release.Name) .Values.global.gitaly.tls.secretName | quote -}}
{{- end -}}

{{/*
Return the gitaly internal port

NOTE: When called from another subchart, e.g. Praefect, it ignores the empty chart-local value.
*/}}
{{- define "gitlab.gitaly.internalPort" -}}
{{- $internalPort := 0 -}}
{{- if hasKey .Values "gitaly" -}}
{{-   $internalPort = .Values.gitaly.service.internalPort -}}
{{- end -}}
{{- coalesce $internalPort .Values.global.gitaly.service.internalPort -}}
{{- end -}}

{{/*
Return the gitaly TLS internal port

NOTE: When called from another subchart, e.g. Praefect, it ignores the empty chart-local value.
*/}}
{{- define "gitlab.gitaly.tls.internalPort" -}}
{{- $internalPort := 0 -}}
{{- if hasKey .Values "gitaly" -}}
{{-   $internalPort = .Values.gitaly.service.tls.internalPort -}}
{{- end -}}
{{- coalesce $internalPort .Values.global.gitaly.service.tls.internalPort -}}
{{- end -}}

{{/*
Return the gitaly service name

Order of operations:
- chart-local gitaly service name override
- global gitaly service name override
- derived from chart name

NOTE: When called from another subchart, e.g. Praefect, it ignores chart-local values if empty.
*/}}
{{- define "gitlab.gitaly.serviceName" -}}
{{- $serviceName := "" -}}
{{- if hasKey .Values "gitaly" -}}
{{-   $serviceName = .Values.gitaly.serviceName -}}
{{- end -}}
{{- coalesce $serviceName .Values.global.gitaly.serviceName (include "gitlab.other.fullname" (dict "context" . "chartName" "gitaly" )) -}}
{{- end -}}

{{/*
Return a qualified gitaly service name, for direct access to the gitaly headless service endpoint of a pod.

Call:

```
{{- include "gitlab.gitaly.qualifiedServiceName" (dict "context" . "index" $i) -}}
```
*/}}
{{- define "gitlab.gitaly.qualifiedServiceName" -}}
{{- $name := include "gitlab.gitaly.serviceName" .context -}}
{{ include "gitlab.other.fullname" (dict "context" .context "chartName" "gitaly" ) }}-{{ .index }}.{{ $name }}
{{- end -}}
