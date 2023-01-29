{{/* Configmap Spawwner */}}
{{/* Call this template:
{{ include "ix.v1.common.spawner.configmaps" $ -}}
*/}}

{{- define "ix.v1.common.spawner.configmaps" -}}

  {{- range $name, $configmap := .Values.configmaps -}}

    {{- if $configmap.enabled -}}

      {{/* Create a copy of the configmap */}}
      {{- $objectData := (mustDeepCopy $configmap) -}}

      {{/* Set the name of the configmap */}}
      {{- $_ := set $objectData "name" (printf "%s-%s" (include "ix.common.lib.chart.names.fullname" $) $name) -}}
      {{/* Call class to create the object */}}
      {{- include "ix.v1.common.class.configmap" (dict "objectData" $objectData "rootCtx" $) -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
