{{/* Image Pull Secrets Spawner */}}
{{/* Call this template:
{{ include "ix.v1.common.spawner.imagePullSecret" $ -}}
*/}}

{{- define "ix.v1.common.spawner.imagePullSecret" -}}

  {{- range $name, $imgPullSecret := .Values.imagePullSecret -}}

    {{- if $imgPullSecret.enabled -}}

      {{/* Create a copy of the configmap */}}
      {{- $objectData := (mustDeepCopy $imgPullSecret) -}}

      {{- $objectName := (printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $) $name) -}}

      {{/* Perform validations */}}
      {{- include "ix.v1.common.lib.chart.names.validation" (dict "name" $objectName) -}}
      {{- include "ix.v1.common.lib.imagePullSecret.validation" (dict "objectData" $objectData) -}}
      {{- include "ix.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "Image Pull Secret") -}}
      {{- $data := include "ix.v1.common.lib.imagePullSecret.createData" (dict "rootCtx" $ "objectData" $objectData) -}}

      {{/* Update the data */}}
      {{- $_ := set $objectData "data" $data -}}

      {{/* Set the type to Image Pull Secret */}}
      {{- $_ := set $objectData "type" "imagePullSecret" -}}

      {{/* Set the name of the image pull secret */}}
      {{- $_ := set $objectData "name" $objectName -}}
      {{- $_ := set $objectData "shortName" $name -}}

      {{/* Call class to create the object */}}
      {{- include "ix.v1.common.class.secret" (dict "rootCtx" $ "objectData" $objectData) -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
