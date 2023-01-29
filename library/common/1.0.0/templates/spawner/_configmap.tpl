{{/* Configmap Spawwner */}}
{{/* Call this template:
{{ include "ix.v1.common.spawner.configmaps" $ -}}
*/}}

{{- define "ix.v1.common.spawner.configmaps" -}}

  {{- range $name, $configmap := .Values.configmaps -}}

    {{- if $configmap.enabled -}}

      {{/* Create a copy of the configmap */}}
      {{- $objectData := (mustDeepCopy $configmap) -}}

      {{- $objectName := (printf "%s-%s" (include "ix.common.lib.chart.names.fullname" $) $name) -}}
      {{/* Perform validations */}}
      {{- include "ix.v1.common.lib.chart.names.validation" (dict "name" $objectName) -}}
      {{- include "ix.v1.common.lib.configmap.validation" (dict "objectData" $objectData) -}}

      {{/* Set the name of the configmap */}}
      {{- $_ := set $objectData "name" $objectName -}}
      {{/* Call class to create the object */}}
      {{- include "ix.v1.common.class.configmap" (dict "objectData" $objectData "rootCtx" $) -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
