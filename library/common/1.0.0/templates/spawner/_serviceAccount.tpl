{{/* Service Account Spawner */}}
{{/* Call this template:
{{ include "ix.v1.common.spawner.serviceAccounts" $ -}}
*/}}

{{- define "ix.v1.common.spawner.serviceAccounts" -}}

  {{/* Primary validation for enabled service accounts. */}}
  {{- include "ix.v1.common.lib.serviceAccount.primaryValidation" $ -}}

  {{- range $name, $serviceAccount := .Values.serviceAccounts -}}

    {{- if $serviceAccount.enabled -}}

      {{/* Create a copy of the configmap */}}
      {{- $objectData := (mustDeepCopy $serviceAccount) -}}

      {{- $objectName := include "ix.v1.common.lib.chart.names.fullname" $ -}}
      {{- if not $objectData.primary -}}
        {{- $objectName = (printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $) $name) -}}
      {{- end -}}

      {{/* Perform validations */}}
      {{- include "ix.v1.common.lib.chart.names.validation" (dict "name" $objectName) -}}
      {{- include "ix.v1.common.lib.serviceAccount.validation" (dict "objectData" $objectData) -}}

      {{/* Set the name of the service account */}}
      {{- $_ := set $objectData "name" $objectName -}}

      {{/* Call class to create the object */}}
      {{- include "ix.v1.common.class.serviceAccount" (dict "rootCtx" $ "objectData" $objectData) -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
