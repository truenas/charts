{{/* Configmap Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.imagePullSecret.createData" (dict "objectData" $objectData "root" $rootCtx) -}}
rootCtx: The root context of the chart.
objectData:
  data: The data of the imagePullSecret.
*/}}

{{- define "ix.v1.common.lib.imagePullSecret.createData" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}

  {{- $registrySecret := dict -}}

  {{/* Auth is b64encoded and then the whole secret is b64encoded */}}
  {{- $auth := printf "%s:%s" (tpl $objectData.data.username $rootCtx) (tpl $objectData.data.password $rootCtx) | b64enc -}}

  {{- $registry := dict -}}
  {{- with $objectData.data -}}
    {{- $registry = (dict "username" (tpl .username $rootCtx) "password" (tpl .password $rootCtx)
                            "email" (tpl .email $rootCtx) "auth" $auth) -}}
  {{- end -}}

  {{- $_ := set $registrySecret "auths" (dict "registry" $registry) -}}

  {{/*
  This should result in something like this:
    {
      "auths": {
        "$registry": {
          "username": "$username",
          "password": "$password",
          "email": "$email",
          "auth": "($username:$password) base64"
        }
      }
}
*/}}

  {{/* Return the registrySecret as Json */}}
  {{- $registrySecret | toJson -}}
{{- end -}}
