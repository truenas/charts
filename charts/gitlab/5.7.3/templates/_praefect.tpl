{{/*
Return Praefect's dbSecert secret name
*/}}
{{- define "gitlab.praefect.dbSecret.secret" -}}
{{- default (printf "%s-praefect-dbsecret" .Release.Name) .Values.global.praefect.dbSecret.secret | quote -}}
{{- end -}}

{{/*
Return Praefect's dbSecert secret key
*/}}
{{- define "gitlab.praefect.dbSecret.key" -}}
{{- default "secret" .Values.global.praefect.dbSecret.key | quote -}}
{{- end -}}

{{/*
Return Praefect's database hostname
*/}}
{{- define "gitlab.praefect.psql.host" -}}
{{- coalesce .Values.global.praefect.psql.host (include "gitlab.psql.host" .)  }}
{{- end -}}

{{/*
Return Praefect's database port
*/}}
{{- define "gitlab.praefect.psql.port" -}}
{{- coalesce .Values.global.praefect.psql.port (include "gitlab.psql.port" .) }}
{{- end -}}

{{/*
Return Praefect's database username
*/}}
{{- define "gitlab.praefect.psql.user" -}}
{{- default "praefect" .Values.global.praefect.psql.user }}
{{- end -}}

{{/*
Return Praefect's database name
*/}}
{{- define "gitlab.praefect.psql.dbName" -}}
{{- default "praefect" .Values.global.praefect.psql.dbName }}
{{- end -}}

{{/*
Return the praefect secret name
Preference is local, global, default (`praefect-secret`)
*/}}
{{- define "gitlab.praefect.authToken.secret" -}}
{{- coalesce .Values.global.praefect.authToken.secret (printf "%s-praefect-secret" .Release.Name) | quote -}}
{{- end -}}

{{/*
Return the praefect secret key
Preference is local, global, default (`token`)
*/}}
{{- define "gitlab.praefect.authToken.key" -}}
{{- coalesce .Values.global.praefect.authToken.key "token" | quote -}}
{{- end -}}

{{/*
Return the praefect internal port
*/}}
{{- define "gitlab.praefect.internalPort" -}}
{{- $internalPort := 0 -}}
{{- if hasKey .Values "praefect" -}}
{{-   if hasKey .Values.praefect "service" -}}
{{-     $internalPort = .Values.praefect.service.internalPort -}}
{{-   end -}}
{{- end -}}
{{- coalesce $internalPort .Values.global.praefect.service.internalPort -}}
{{- end -}}

{{/*
Return the praefect TLS internal port
*/}}
{{- define "gitlab.praefect.tls.internalPort" -}}
{{- $internalPort := 0 -}}
{{- if hasKey .Values "praefect" -}}
{{-   if hasKey .Values.praefect "service" -}}
{{-     if hasKey .Values.praefect.service "tls" -}}
{{-       $internalPort = .Values.praefect.service.tls.internalPort -}}
{{-     end -}}
{{-   end -}}
{{- end -}}
{{- coalesce $internalPort .Values.global.praefect.service.tls.internalPort -}}
{{- end -}}

{{/*
Return the praefect external port
*/}}
{{- define "gitlab.praefect.externalPort" -}}
{{- $externalPort := 0 -}}
{{- if hasKey .Values "praefect" -}}
{{-   if hasKey .Values.praefect "service" -}}
{{-     $externalPort = .Values.praefect.service.externalPort -}}
{{-   end -}}
{{- end -}}
{{- coalesce $externalPort .Values.global.praefect.service.externalPort -}}
{{- end -}}

{{/*
Return the praefect TLS external port
*/}}
{{- define "gitlab.praefect.tls.externalPort" -}}
{{- $externalPort := 0 -}}
{{- if hasKey .Values "praefect" -}}
{{-   if hasKey .Values.praefect "service" -}}
{{-     $externalPort = .Values.praefect.service.tls.externalPort -}}
{{-   end -}}
{{- end -}}
{{- coalesce $externalPort .Values.global.praefect.service.tls.externalPort -}}
{{- end -}}

{{/*
Return the praefect TLS secret name
*/}}
{{- define "gitlab.praefect.tls.secret" -}}
{{-   default (printf "%s-praefect-tls" .Release.Name) .Values.global.praefect.tls.secretName | quote -}}
{{- end -}}
