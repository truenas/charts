{{/*
Protect against problems in storage names within repositories configuration.
- Ensure that one (and only one) storage is named 'default'.
- Ensure no duplicates

Collects the list of storage names by rendering the 'gitlab.appConfig.repositories'
template, and grabbing any lines that start with exactly 4 spaces.
*/}}
{{- define "gitlab.checkConfig.gitaly.storageNames" -}}
{{- $errorMsg := list -}}
{{- $config := include "gitlab.appConfig.repositories" $ -}}
{{- $storages := list }}
{{- range (splitList "\n" $config) -}}
{{-   if (regexMatch "^    [^ ]" . ) -}}
{{-     $storages = append $storages (trim . | trimSuffix ":") -}}
{{-   end }}
{{- end }}
{{- if gt (len $storages) (len (uniq $storages)) -}}
{{-   $errorMsg = append $errorMsg (printf "Each storage name must be unique. Current storage names: %s" $storages | sortAlpha | join ", ") -}}
{{- end -}}
{{- if not (has "default" $storages) -}}
{{-   $errorMsg = append $errorMsg ("There must be one (and only one) storage named 'default'.") -}}
{{- end }}
{{- if not (empty $errorMsg) }}
gitaly:
{{- range $msg := $errorMsg }}
    {{ $msg }}
{{- end }}
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.gitaly.storageNames -}}

{{/*
Ensure that if a user is migrating to Praefect, none of the Praefect virtual storage
names are 'default', as it should already be used by the non-Praefect storage configuration.
*/}}
{{- define "gitlab.checkConfig.praefect.storageNames" -}}
{{- if and $.Values.global.gitaly.enabled $.Values.global.praefect.enabled (not $.Values.global.praefect.replaceInternalGitaly) -}}
{{-   range $i, $vs := $.Values.global.praefect.virtualStorages -}}
{{-     if eq $vs.name "default" -}}
praefect:
    Praefect is enabled, but `global.praefect.replaceInternalGitaly=false`. In this scenario,
    none of the Praefect virtual storage names can be 'default'. Please modify
    `global.praefect.virtualStorages[{{ $i }}].name`.
{{-     end }}
{{-   end }}
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.praefect.storageNames" -}}

{{/*
Ensure a certificate is provided when Gitaly is enabled and is instructed to
listen over TLS */}}
{{- define "gitlab.checkConfig.gitaly.tls" -}}
{{- $errorMsg := list -}}
{{- if and $.Values.global.gitaly.enabled $.Values.global.gitaly.tls.enabled -}}
{{-   if $.Values.global.praefect.enabled -}}
{{-     range $i, $vs := $.Values.global.praefect.virtualStorages -}}
{{-       if not $vs.tlsSecretName }}
{{-         $errorMsg = append $errorMsg (printf "global.praefect.virtualStorages[%d].tlsSecretName not specified ('%s')" $i $vs.name) -}}
{{-       end }}
{{-     end }}
{{-   else }}
{{-     if not $.Values.global.gitaly.tls.secretName -}}
{{-       $errorMsg = append $errorMsg ("global.gitaly.tls.secretName not specified") -}}
{{-     end }}
{{-   end }}
{{- end }}
{{- if not (empty $errorMsg) }}
gitaly:
{{- range $msg := $errorMsg }}
    {{ $msg }}
{{- end }}
    This configuration is not supported.
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.gitaly.tls */}}

{{/*
Ensure a certificate is provided when Praefect is enabled and is instructed to listen over TLS
*/}}
{{- define "gitlab.checkConfig.praefect.tls" -}}
{{- if and (and $.Values.global.praefect.enabled $.Values.global.praefect.tls.enabled) (not $.Values.global.praefect.tls.secretName) }}
praefect: server enabled with TLS, no TLS certificate provided
    It appears Praefect is specified to listen over TLS, but no certificate was specified.
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.praefect.tls */}}

{{/* Check configuration of Gitaly external repos*/}}
{{- define "gitlab.checkConfig.gitaly.extern.repos" -}}
{{-   if (and (not .Values.global.gitaly.enabled) (not .Values.global.gitaly.external) ) }}
gitaly:
    external Gitaly repos needs to be specified if global.gitaly.enabled is not set
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.gitaly.extern.repos */}}
