{{/* Service Account Spawner */}}
{{/* Call this template:
{{ include "ix.v1.common.spawner.serviceAccounts" $ -}}
*/}}

{{- define "ix.v1.common.spawner.serviceAccounts" -}}

  {{- range $name, $serviceAccount := .Values.serviceAccounts -}}

    {{- if $serviceAccount.enabled -}}

      {{/* Create a copy of the configmap */}}
      {{- $objectData := (mustDeepCopy $serviceAccount) -}}

      {{- $objectName := (printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $) $name) -}}

      {{/* Perform validations */}}
      {{- include "ix.v1.common.lib.chart.names.validation" (dict "name" $objectName) -}}

      {{/* Set the name of the service account */}}
      {{- $_ := set $objectData "name" $objectName -}}

      {{/* Call class to create the object */}}
      {{- include "ix.v1.common.class.serviceAccount" (dict "rootCtx" $ "objectData" $objectData) -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
