{{/*
Retrieve true/false if certificate is configured
*/}}
{{- define "nginx.certAvailable" -}}
{{- if .Values.certificate -}}
{{- $values := (. | mustDeepCopy) -}}
{{- $_ := set $values "commonCertOptions" (dict "certKeyName" $values.Values.certificate) -}}
{{- template "common.resources.cert_present" $values -}}
{{- else -}}
{{- false -}}
{{- end -}}
{{- end -}}


{{/*
Retrieve public key of certificate
*/}}
{{- define "nginx.cert.publicKey" -}}
{{- $values := (. | mustDeepCopy) -}}
{{- $_ := set $values "commonCertOptions" (dict "certKeyName" $values.Values.certificate "publicKey" true) -}}
{{ include "common.resources.cert" $values }}
{{- end -}}


{{/*
Retrieve private key of certificate
*/}}
{{- define "nginx.cert.privateKey" -}}
{{- $values := (. | mustDeepCopy) -}}
{{- $_ := set $values "commonCertOptions" (dict "certKeyName" $values.Values.certificate) -}}
{{ include "common.resources.cert" $values }}
{{- end -}}


{{/*
Retrieve configured protocol scheme for nextcloud
*/}}
{{- define "nginx.scheme" -}}
{{- if eq (include "nginx.certAvailable" .) "true" -}}
{{- print "https" -}}
{{- else -}}
{{- print "http" -}}
{{- end -}}
{{- end -}}
