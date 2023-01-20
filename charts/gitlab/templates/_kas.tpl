{{/* ######### gitlab-kas related templates */}}

{{/*
Return the gitlab-kas secret
*/}}

{{- define "gitlab.kas.secret" -}}
{{- default (printf "%s-gitlab-kas-secret" .Release.Name) .Values.global.appConfig.gitlab_kas.secret | quote -}}
{{- end -}}

{{- define "gitlab.kas.key" -}}
{{- default "kas_shared_secret" .Values.global.appConfig.gitlab_kas.key | quote -}}
{{- end -}}

{{/*
Return the gitlab-kas private API secret
*/}}

{{- define "gitlab.kas.privateApi.secret" -}}
{{- $secret := "" -}}
{{- if eq .Chart.Name "kas" -}}
{{-    $secret = .Values.privateApi.secret -}}
{{- else -}}
{{-    $secret = .Values.gitlab.kas.privateApi.secret -}}
{{- end -}}
{{- default (printf "%s-kas-private-api" .Release.Name) $secret | quote -}}
{{- end -}}

{{- define "gitlab.kas.privateApi.key" -}}
{{- $key := "" -}}
{{- if eq .Chart.Name "kas" -}}
{{-    $key = .Values.privateApi.key -}}
{{- else -}}
{{-    $key = .Values.gitlab.kas.privateApi.key -}}
{{- end -}}
{{- default "kas_private_api_secret" $key | quote -}}
{{- end -}}
