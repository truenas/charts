{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Run "fullname" as if it was in another chart. This is an imperfect emulation, but close.

This is especially useful when you reference "fullname" services/pods which may or may not be easy to reconstruct.

Call:

```
{{- include "gitlab.other.fullname" ( dict "context" . "chartName" "name-of-other-chart" ) -}}
```
*/}}
{{- define "gitlab.other.fullname" -}}
{{- $Chart := dict "Name" .chartName -}}
{{- $Release := .context.Release -}}
{{- $localNameOverride :=  (pluck "nameOverride" (pluck .chartName .context.Values | first) | first) -}}
{{- $globalNameOverride :=  (pluck "nameOverride" (pluck .chartName .context.Values.global | first) | first) -}}
{{- $nameOverride :=  coalesce $localNameOverride $globalNameOverride -}}
{{- $Values := dict "nameOverride" $nameOverride "global" .context.Values.global -}}
{{- include "fullname" (dict "Chart" $Chart "Release" $Release "Values" $Values) -}}
{{- end -}}

{{/* ######### Hostname templates */}}

{{/*
Returns the hostname.
If the hostname is set in `global.hosts.gitlab.name`, that will be returned,
otherwise the hostname will be assembled using `gitlab` as the prefix, and the `gitlab.assembleHost` function.
*/}}
{{- define "gitlab.gitlab.hostname" -}}
{{- coalesce .Values.global.hosts.gitlab.name (include "gitlab.assembleHost"  (dict "name" "gitlab" "context" . )) -}}
{{- end -}}

{{/*
Returns the GitLab Url, ex: `http://gitlab.example.com`
If `global.hosts.https` or `global.hosts.gitlab.https` is true, it uses https, otherwise http.
Calls into the `gitlab.gitlabHost` function for the hostname part of the url.
*/}}
{{- define "gitlab.gitlab.url" -}}
{{- if or .Values.global.hosts.https .Values.global.hosts.gitlab.https -}}
{{-   printf "https://%s" (include "gitlab.gitlab.hostname" .) -}}
{{- else -}}
{{-   printf "http://%s" (include "gitlab.gitlab.hostname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Returns the minio hostname.
If the hostname is set in `global.hosts.minio.name`, that will be returned,
otherwise the hostname will be assembled using `minio` as the prefix, and the `gitlab.assembleHost` function.
*/}}
{{- define "gitlab.minio.hostname" -}}
{{- coalesce .Values.global.hosts.minio.name (include "gitlab.assembleHost"  (dict "name" "minio" "context" . )) -}}
{{- end -}}

{{/*
Returns the minio url.
*/}}

{{- define "gitlab.minio.url" -}}
{{- if or .Values.global.hosts.https .Values.global.hosts.minio.https -}}
{{-   printf "https://%s" (include "gitlab.minio.hostname" .) -}}
{{- else -}}
{{-   printf "http://%s" (include "gitlab.minio.hostname" .) -}}
{{- end -}}
{{- end -}}

{{/* ######### Utility templates */}}

{{/*
  A helper function for assembling a hostname using the base domain specified in `global.hosts.domain`
  Takes a `Map/Dictonary` as an argument. Where key `name` is the domain to build, and `context` should be a
  reference to the chart's $ object.
  eg: `template "assembleHost" (dict "name" "minio" "context" .)`

  The hostname will be the combined name with the domain. eg: If domain is `example.com`, it will produce `minio.example.com`
  Additionally if `global.hosts.hostSuffix` is set, it will append a hyphen, then the suffix to the name:
  eg: If hostSuffix is `beta` it will produce `minio-beta.example.com`
*/}}
{{- define "gitlab.assembleHost" -}}
{{- $name := .name -}}
{{- $context := .context -}}
{{- $result := dict -}}
{{- if $context.Values.global.hosts.domain -}}
{{-   $_ := set $result "domainHost" (printf ".%s" $context.Values.global.hosts.domain) -}}
{{-   if $context.Values.global.hosts.hostSuffix -}}
{{-     $_ := set $result "domainHost" (printf "-%s%s" $context.Values.global.hosts.hostSuffix $result.domainHost) -}}
{{-   end -}}
{{-   $_ := set $result "domainHost" (printf "%s%s" $name $result.domainHost) -}}
{{- end -}}
{{- $result.domainHost -}}
{{- end -}}

{{/*
  A helper template for collecting and inserting the imagePullSecrets.

  It expects a dictionary with two entries:
    - `global` which contains global image settings, e.g. .Values.global.image
    - `local` which contains local image settings, e.g. .Values.image
*/}}
{{- define "gitlab.image.pullSecrets" -}}
{{- $pullSecrets := default (list) .global.pullSecrets -}}
{{- if .local.pullSecrets -}}
{{-   $pullSecrets = concat $pullSecrets .local.pullSecrets -}}
{{- end -}}
{{- if $pullSecrets }}
imagePullSecrets:
{{-   range $index, $entry := $pullSecrets }}
- name: {{ $entry.name }}
{{-   end }}
{{- end }}
{{- end -}}

{{/*
  A helper template for inserting imagePullPolicy.

  It expects a dictionary with two entries:
    - `global` which contains global image settings, e.g. .Values.global.image
    - `local` which contains local image settings, e.g. .Values.image
*/}}
{{- define "gitlab.image.pullPolicy" -}}
{{- $pullPolicy := coalesce .local.pullPolicy .global.pullPolicy -}}
{{- if $pullPolicy }}
imagePullPolicy: {{ $pullPolicy | quote }}
{{- end -}}
{{- end -}}

{{/* ######### cert-manager templates */}}

{{- define "gitlab.certmanager_annotations" -}}
{{- if (pluck "configureCertmanager" .Values.ingress .Values.global.ingress (dict "configureCertmanager" false) | first) -}}
cert-manager.io/issuer: "{{ .Release.Name }}-issuer"
{{- end -}}
{{- end -}}

{{/* ######### postgresql templates */}}

{{/*
Return the db hostname
If an external postgresl host is provided, it will use that, otherwise it will fallback
to the service name. Failing a specified service name it will fall back to the default service name.

This overrides the upstream postegresql chart so that we can deterministically
use the name of the service the upstream chart creates
*/}}
{{- define "gitlab.psql.host" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{- coalesce (pluck "host" $local .Values.global.psql | first) (printf "%s.%s.svc" (include "postgresql.fullname" .) $.Release.Namespace) -}}
{{- end -}}

{{/*
Return the configmap for initializing the PostgreSQL database. This is used to enable the
necessary postgres extensions for Gitlab to work
This overrides the upstream postegresql chart so that we can deterministically
use the name of the initdb scripts ConfigMap the upstream chart creates
*/}}
{{- define "gitlab.psql.initdbscripts" -}}
{{- printf "%s-%s-%s" .Release.Name "postgresql" "init-db" -}}
{{- end -}}

{{/*
Alias of gitlab.psql.initdbscripts
*/}}
{{- define "postgresql.initdbScriptsCM" -}}
{{- template "gitlab.psql.initdbscripts" . -}}
{{- end -}}

{{/*
Overrides the full name of PostegreSQL in the upstream chart.
*/}}
{{- define "postgresql.fullname" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{- coalesce (pluck "serviceName" $local .Values.global.psql | first) (printf "%s-%s" $.Release.Name "postgresql") -}}
{{- end -}}

{{/*
Return the db database name
*/}}
{{- define "gitlab.psql.database" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{- coalesce (pluck "database" $local .Values.global.psql | first) "gitlabhq_production" -}}
{{- end -}}

{{/*
Return the db username
If the postgresql username is provided, it will use that, otherwise it will fallback
to "gitlab" default
*/}}
{{- define "gitlab.psql.username" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{- coalesce (pluck "username" $local .Values.global.psql | first) "gitlab" -}}
{{- end -}}

{{/*
Return the db port
If the postgresql port is provided in subchart values or global values, it will use that, otherwise it will fallback
to 5432 default
*/}}
{{- define "gitlab.psql.port" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{- default 5432 (pluck "port" $local $.Values.global.psql | first ) | int -}}
{{- end -}}

{{/*
Return the secret name
Defaults to a release-based name and falls back to .Values.global.psql.secretName
  when using an external PostgreSQL
*/}}
{{- define "gitlab.psql.password.secret" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{- $localPass := pluck "password" $local | first -}}
{{- default (printf "%s-%s" .Release.Name "postgresql-password") (pluck "secret" $localPass $.Values.global.psql.password | first ) | quote -}}
{{- end -}}

{{/*
Alias of gitlab.psql.password.secret to override upstream postgresql chart naming
*/}}
{{- define "postgresql.secretName" -}}
{{- template "gitlab.psql.password.secret" . -}}
{{- end -}}

{{/*
Return the name of the key in a secret that contains the postgres password
Uses `postgresql-password` to match upstream postgresql chart when not using an
  external postegresql
*/}}
{{- define "gitlab.psql.password.key" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{- $localPass := pluck "password" $local | first -}}
{{- default "postgresql-password" (pluck "key" $localPass $.Values.global.psql.password | first ) | quote -}}
{{- end -}}

{{/*
Return the application name that should be presented to PostgreSQL.
A blank string tells the client NOT to send an application name.
A nil value will use the process name by default.
See https://github.com/Masterminds/sprig/issues/53 for how we distinguish these.
Defaults to nil.
*/}}
{{- define "gitlab.psql.applicationName" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{- $appname := pluck "applicationName" $local .Values.global.psql | first -}}
{{- if not ( kindIs "invalid" $appname ) -}}
{{- $appname | quote -}}
{{- end -}}
{{- end -}}

{{/*
Return if prepared statements should be used by PostgreSQL.
Defaults to false
*/}}
{{- define "gitlab.psql.preparedStatements" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{- eq true (default false (pluck "preparedStatements" $local .Values.global.psql | first)) -}}
{{- end -}}

{{/*
Return connect_timeout value
Defaults to nil
*/}}
{{- define "gitlab.psql.connectTimeout" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{ pluck "connectTimeout" $local .Values.global.psql | first -}}
{{- end -}}

{{/*
Return keepalives value
Defaults to nil
*/}}
{{- define "gitlab.psql.keepalives" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{ pluck "keepalives" $local .Values.global.psql | first -}}
{{- end -}}

{{/*
Return keepalives_idle value
Defaults to nil
*/}}
{{- define "gitlab.psql.keepalivesIdle" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{ pluck "keepalivesIdle" $local .Values.global.psql | first -}}
{{- end -}}

{{/*
Return keepalives_interval value
Defaults to nil
*/}}
{{- define "gitlab.psql.keepalivesInterval" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{ pluck "keepalivesInterval" $local .Values.global.psql | first -}}
{{- end -}}

{{/*
Return keepalives_count value
Defaults to nil
*/}}
{{- define "gitlab.psql.keepalivesCount" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{ pluck "keepalivesCount" $local .Values.global.psql | first -}}
{{- end -}}

{{/*
Return tcp_user_timeout value
Defaults to nil
*/}}
{{- define "gitlab.psql.tcpUserTimeout" -}}
{{- $local := pluck "psql" $.Values | first -}}
{{ pluck "tcpUserTimeout" $local .Values.global.psql | first -}}
{{- end -}}

{{/* ######### ingress templates */}}

{{/*
Return the appropriate apiVersion for Ingress.

It expects a dictionary with three entries:
  - `global` which contains global ingress settings, e.g. .Values.global.ingress
  - `local` which contains local ingress settings, e.g. .Values.ingress
  - `context` which is the parent context (either `.` or `$`)

Example usage:
{{- $ingressCfg := dict "global" .Values.global.ingress "local" .Values.ingress "context" . -}}
kubernetes.io/ingress.provider: "{{ template "gitlab.ingress.provider" $ingressCfg }}"
*/}}
{{- define "gitlab.ingress.apiVersion" -}}
{{-   if .local.apiVersion -}}
{{-     .local.apiVersion -}}
{{-   else if .global.apiVersion -}}
{{-     .global.apiVersion -}}
{{-   else if .context.Capabilities.APIVersions.Has "networking.k8s.io/v1/Ingress" -}}
{{-     print "networking.k8s.io/v1" -}}
{{-   else if .context.Capabilities.APIVersions.Has "networking.k8s.io/v1beta1/Ingress" -}}
{{-     print "networking.k8s.io/v1beta1" -}}
{{-   else -}}
{{-     print "extensions/v1beta1" -}}
{{-   end -}}
{{- end -}}

{{/*
Returns the ingress provider

It expects a dictionary with two entries:
  - `global` which contains global ingress settings, e.g. .Values.global.ingress
  - `local` which contains local ingress settings, e.g. .Values.ingress
*/}}
{{- define "gitlab.ingress.provider" -}}
{{- default .global.provider .local.provider -}}
{{- end -}}

{{/*
Overrides the ingress-nginx template to make sure gitlab-shell name matches
*/}}
{{- define "ingress-nginx.tcp-configmap" -}}
{{ .Release.Name}}-nginx-ingress-tcp
{{- end -}}

{{/* ######### annotations */}}

{{/*
Handles merging a set of service annotations
*/}}
{{- define "gitlab.serviceAnnotations" -}}
{{- $allAnnotations := merge (default (dict) (default (dict) .Values.service).annotations) .Values.global.service.annotations -}}
{{- if $allAnnotations }}
{{- toYaml $allAnnotations -}}
{{- end -}}
{{- end -}}

{{/*
Handles merging a set of deployment annotations
*/}}
{{- define "gitlab.deploymentAnnotations" -}}
{{- $allAnnotations := merge (default (dict) (default (dict) .Values.deployment).annotations) .Values.global.deployment.annotations -}}
{{- if $allAnnotations -}}
{{- toYaml $allAnnotations -}}
{{- end -}}
{{- end -}}

{{/* ######### labels */}}

{{/*
Handles merging a set of non-selector labels
*/}}
{{- define "gitlab.podLabels" -}}
{{- $allLabels := merge (default (dict) .Values.podLabels) .Values.global.pod.labels -}}
{{- if $allLabels -}}
{{-   range $key, $value := $allLabels }}
{{ $key }}: {{ $value | quote }}
{{-   end }}
{{- end -}}
{{- end -}}

{{/*
Handles merging a set of labels for services
*/}}
{{- define "gitlab.serviceLabels" -}}
{{- $allLabels := merge (default (dict) .Values.serviceLabels) .Values.global.service.labels -}}
{{- if $allLabels -}}
{{-   range $key, $value := $allLabels }}
{{ $key }}: {{ $value | quote }}
{{-   end }}
{{- end -}}
{{- end -}}

{{/* selfsigned cert for when other options aren't provided */}}
{{- define "gitlab.wildcard-self-signed-cert-name" -}}
{{- default (printf "%s-wildcard-tls" .Release.Name) .Values.global.ingress.tls.secretName -}}
{{- end -}}

{{/*
Detect if `x.ingress.tls.secretName` are set
Return value if either `global.ingress.tls.secretName` or all three `x.ingress.tls.secretName` are set.
Return empty if not

We're explicitly checking for an actual value being present, not the existance of map.
*/}}
{{- define "gitlab.ingress.tls.configured" -}}
{{/* Pull the value, if it exists */}}
{{- $global      := pluck "secretName" (default (dict)  $.Values.global.ingress.tls) | first -}}
{{- $webservice  := pluck "secretName" $.Values.gitlab.webservice.ingress.tls | first -}}
{{- $registry    := pluck "secretName" $.Values.registry.ingress.tls | first -}}
{{- $minio       := pluck "secretName" $.Values.minio.ingress.tls | first -}}
{{- $smartcard   := pluck "smartcardSecretName" $.Values.gitlab.webservice.ingress.tls | first -}}
{{/* Set each item to configured value, or !enabled
     This works because `false` is the same as empty, so we'll use the value when `enabled: true`
     - default "" (not true) => ''
     - default "" (not false) => 'true'
     - default "valid" (not true) => 'valid'
     - default "valid" (not false) => 'true'
     Now, disabled sub-charts won't block this template from working properly.
*/}}
{{- $webservice  :=  default $webservice (not $.Values.gitlab.webservice.enabled) -}}
{{- $registry    :=  default $registry (not $.Values.registry.enabled) -}}
{{- $minio       :=  default $minio (not $.Values.global.minio.enabled) -}}
{{- $smartcard   :=  default $smartcard (not $.Values.global.appConfig.smartcard.enabled) -}}
{{/* Check that all enabled items have been configured */}}
{{- if or $global (and $webservice $registry $minio $smartcard) -}}
true
{{- end -}}
{{- end -}}

{{/*
Detect if `.Values.ingress.tls.enabled` is set
Returns `ingress.tls.enabled` if it is a boolean,
Returns `global.ingress.tls.enabled` if it is a boolean, and `ingress.tls.enabled` is not.
Return true in any other case.
*/}}
{{- define "gitlab.ingress.tls.enabled" -}}
{{- $globalSet := and (hasKey .Values.global.ingress "tls") (and (hasKey .Values.global.ingress.tls "enabled") (kindIs "bool" .Values.global.ingress.tls.enabled)) -}}
{{- $localSet := and (hasKey .Values.ingress "tls") (and (hasKey .Values.ingress.tls "enabled") (kindIs "bool" .Values.ingress.tls.enabled)) -}}
{{- if $localSet }}
{{-   .Values.ingress.tls.enabled }}
{{- else if $globalSet }}
{{-  .Values.global.ingress.tls.enabled }}
{{- else }}
{{-   true }}
{{- end -}}
{{- end -}}

{{/*
Detect if `.Values.ingress.enabled` is set
Returns `ingress.enabled` if it is a boolean,
Returns `global.ingress.enabled` if it is a boolean, and `ingress.enabled` is not.
Return true in any other case.
*/}}
{{- define "gitlab.ingress.enabled" -}}
{{- $globalSet := and (hasKey .Values.global.ingress "enabled") (kindIs "bool" .Values.global.ingress.enabled) -}}
{{- $localSet := and (hasKey .Values.ingress "enabled") (kindIs "bool" .Values.ingress.enabled) -}}
{{- if $localSet }}
{{-   .Values.ingress.enabled }}
{{- else if $globalSet }}
{{-  .Values.global.ingress.enabled }}
{{- else }}
{{-   true }}
{{- end -}}
{{- end -}}

{{/*
Constructs kubectl image name.
*/}}
{{- define "gitlab.kubectl.image" -}}
{{- printf "%s:%s" .Values.global.kubectl.image.repository .Values.global.kubectl.image.tag -}}
{{- end -}}

{{/*
Constructs busybox image name.
*/}}
{{- define "gitlab.busybox.image" -}}
{{/*
    # Earlier, init.image and init.tag were used to configure initContainer
    # image details. We deprecated them in favor of init.image.repository and
    # init.image.tag. However, deprecation checking happens after template
    # rendering is done. So, we have to handle the case of `init.image` being a
    # string to avoid the process being broken at rendering stage itself. It
    # doesn't matter what we print there because once rendering is done
    # deprecation check will kick-in and abort the process. That value will not
    # be used.
*/}}
{{- if kindIs "map" .local.image }}
{{- $image := default .global.image.repository .local.image.repository }}
{{- $tag := default .global.image.tag .local.image.tag }}
{{- printf "%s:%s" $image $tag -}}
{{- else }}
{{- printf "DEPRECATED:DEPRECATED" -}}
{{- end -}}
{{- end -}}

{{/*
Override upstream redis chart naming
*/}}
{{- define "redis.secretName" -}}
{{ template "gitlab.redis.password.secret" . }}
{{- end -}}

{{/*
Override upstream redis secret key name
*/}}
{{- define "redis.secretPasswordKey" -}}
{{ template "gitlab.redis.password.key" . }}
{{- end -}}

{{/*
Return the fullname template for shared-secrets job.
*/}}
{{- define "shared-secrets.fullname" -}}
{{- printf "%s-shared-secrets" .Release.Name -}}
{{- end -}}

{{/*
Return the name template for shared-secrets job.
*/}}
{{- define "shared-secrets.name" -}}
{{- $sharedSecretValues := index .Values "shared-secrets" -}}
{{- default "shared-secrets" $sharedSecretValues.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified job name for shared-secrets.
Due to the job only being allowed to run once, we add the chart revision so helm
upgrades don't cause errors trying to create the already ran job.
Due to the helm delete not cleaning up these jobs, we add a randome value to
reduce collision
*/}}
{{- define "shared-secrets.jobname" -}}
{{- $name := include "shared-secrets.fullname" . | trunc 55 | trimSuffix "-" -}}
{{- $rand := randAlphaNum 3 | lower }}
{{- printf "%s-%d-%s" $name .Release.Revision $rand | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account to use for shared-secrets job
*/}}
{{- define "shared-secrets.serviceAccountName" -}}
{{- $sharedSecretValues := index .Values "shared-secrets" -}}
{{- if $sharedSecretValues.serviceAccount.create -}}
    {{ default (include "shared-secrets.fullname" .) $sharedSecretValues.serviceAccount.name }}
{{- else -}}
    {{ coalesce $sharedSecretValues.serviceAccount.name .Values.global.serviceAccount.name "default" }}
{{- end -}}
{{- end -}}

{{/*
Return a emptyDir definition for Volume declarations

Scope is the configuration of that emptyDir.
Only accepts sizeLimit and/or medium
*/}}
{{- define "gitlab.volume.emptyDir" -}}
{{- $values := pick . "sizeLimit" "medium" -}}
{{- if not $values -}}
emptyDir: {}
{{- else -}}
emptyDir: {{ toYaml $values | nindent 2 }}
{{- end -}}
{{- end -}}
