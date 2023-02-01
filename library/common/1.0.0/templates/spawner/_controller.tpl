{{/* Controller Spawner */}}
{{/* Call this template:
{{ include "ix.v1.common.spawner.controllers" $ -}}
*/}}

{{- define "ix.v1.common.spawner.controllers" -}}

  {{/* Primary validation for enabled controllers. */}}
  {{- include "ix.v1.common.lib.controllers.primaryValidation" $ -}}

  {{- range $name, $controller := .Values.controllers -}}

    {{- if $controller.enabled -}}

      {{/* Create a copy of the controller */}}
      {{- $objectData := (mustDeepCopy $controller) -}}

      {{/* Generate the name of the controller */}}
      {{- $objectName := include "ix.v1.common.lib.chart.names.fullname" $ -}}
      {{- if not $objectData.primary -}}
        {{- $objectName = printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $) $name -}}
      {{- end -}}

      {{/* Perform validations */}}
      {{- include "ix.v1.common.lib.chart.names.validation" (dict "name" $objectName) -}}
      {{- include "ix.v1.common.lib.controller.basicValidation" (dict "objectData" $objectData) -}}

      {{/* Set the name of the controller */}}
      {{- $_ := set $objectData "name" $objectName -}}

      {{/* Short name is the one that defined on the chart, used on selectors */}}
      {{- $_ := set $objectData "shortName" $name -}}

      {{/* Call class to create the object */}}
      {{- if eq $objectData.type "Deployment" -}}
        {{- include "ix.v1.common.class.deployment" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- else if eq $objectData.type "StatefulSet" -}}
        {{- include "ix.v1.common.class.statefulset" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- else if eq $objectData.type "DaemonSet" -}}
        {{- include "ix.v1.common.class.daemonset" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- else if eq $objectData.type "Job" -}}
        {{- include "ix.v1.common.class.job" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- else if eq $objectData.type "CronJob" -}}
        {{- include "ix.v1.common.class.cronjob" (dict "rootCtx" $ "objectData" $objectData) -}}
      {{- end -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
