{{- define "briefkasten.validation" -}}
  {{- $smtp := .Values.briefkastenConfig.smtp -}}
  {{- $github := .Values.briefkastenConfig.github -}}
  {{- $google := .Values.briefkastenConfig.google -}}
  {{- $keycloak := .Values.briefkastenConfig.keycloak -}}
  {{- $authentik := .Values.briefkastenConfig.authentik -}}

  {{- $providers := (list "smtp" "github" "google" "keycloak" "authentik") -}}
  {{- $found := false -}}
  {{- range $p := $providers -}}
    {{- $provider := get $.Values.briefkastenConfig $p -}}
    {{- if $provider.enabled -}}
      {{- $found = true -}}
    {{- end -}}
  {{- end -}}

  {{- if not $found -}}
    {{- fail (printf "Briefkasten - One or more auth provider [%s] must be enabled" (join ", " $providers)) -}}
  {{- end -}}

  {{- if $smtp.enabled -}}
    {{- $required := (list "server" "from") -}}
    {{- range $key := $required -}}
      {{- if not (get $smtp $key) -}}
        {{- fail (printf "Briefkasten - Key [%s] is required for SMTP auth provider" $key) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if $github.enabled -}}
    {{- $required := (list "id" "secret") -}}
    {{- range $key := $required -}}
      {{- if not (get $github $key) -}}
        {{- fail (printf "Briefkasten - Key [%s] is required for Github auth provider" $key) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if $google.enabled -}}
    {{- $required := (list "id" "secret") -}}
    {{- range $key := $required -}}
      {{- if not (get $google $key) -}}
        {{- fail (printf "Briefkasten - Key [%s] is required for Google auth provider" $key) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if $keycloak.enabled -}}
    {{- $required := (list "name" "id" "secret" "issuer") -}}
    {{- range $key := $required -}}
      {{- if not (get $keycloak $key) -}}
        {{- fail (printf "Briefkasten - Key [%s] is required for Keycloak auth provider" $key) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- if $authentik.enabled -}}
    {{- $required := (list "name" "id" "secret" "issuer") -}}
    {{- range $key := $required -}}
      {{- if not (get $authentik $key) -}}
        {{- fail (printf "Briefkasten - Key [%s] is required for Authentik auth provider" $key) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
