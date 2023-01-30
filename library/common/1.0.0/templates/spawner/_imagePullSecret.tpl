{{/* Configmap Spawwner */}}
{{/* Call this template:
{{ include "ix.v1.common.spawner.imagePullSecrets" $ -}}
*/}}

{{- define "ix.v1.common.spawner.imagePullSecrets" -}}

  {{- range $name, $imgPullSecret := .Values.imagePullSecrets -}}

    {{- if $imgPullSecret.enabled -}}

      {{/* Create a copy of the configmap */}}
      {{- $objectData := (mustDeepCopy $imgPullSecret) -}}

      {{- $objectName := (printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $) $name) -}}
      {{/* Perform validations */}}
      {{- include "ix.v1.common.lib.chart.names.validation" (dict "name" $objectName) -}}
      {{- include "ix.v1.common.lib.imagePullSecret.validation" (dict "objectData" $objectData) -}}
      {{- $data := include "ix.v1.common.lib.imagePullSecret.createData" (dict "objectData" $objectData "rootCtx" $) -}}


      {{/* Update the data */}}
      {{- $_ := set $objectData "data" $data -}}

      {{/* Set the type to Image Pull Secret */}}
      {{- $_ := set $objectData "type" "imagePullSecret" -}}

      {{/* Set the name of the image pull secret */}}
      {{- $_ := set $objectData "name" $objectName -}}

      {{/* Call class to create the object */}}
      {{- include "ix.v1.common.class.secret" (dict "objectData" $objectData "rootCtx" $) -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
