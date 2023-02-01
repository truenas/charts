{{/* Secret Spawwner */}}
{{/* Call this template:
{{ include "ix.v1.common.spawner.secrets" $ -}}
*/}}

{{- define "ix.v1.common.spawner.secrets" -}}

  {{- range $name, $secret := .Values.secrets -}}

    {{- if $secret.enabled -}}

      {{/* Create a copy of the secret */}}
      {{- $objectData := (mustDeepCopy $secret) -}}

      {{- $objectName := (printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $) $name) -}}
      {{/* Perform validations */}}
      {{- include "ix.v1.common.lib.chart.names.validation" (dict "name" $objectName) -}}
      {{- include "ix.v1.common.lib.secret.validation" (dict "objectData" $objectData) -}}

      {{/* Set the name of the secret */}}
      {{- $_ := set $objectData "name" $objectName -}}
      {{/* Call class to create the object */}}
      {{- include "ix.v1.common.class.secret" (dict "rootCtx" $ "objectData" $objectData) -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
