{{/* PVC Spawwner */}}
{{/* Call this template:
{{ include "ix.v1.common.spawner.pvc" $ -}}
*/}}

{{- define "ix.v1.common.spawner.pvc" -}}

  {{- range $name, $persistence := .Values.persistence -}}

    {{- if $persistence.enabled -}}

      {{/* Create a copy of the persistence */}}
      {{- $objectData := (mustDeepCopy $persistence) -}}

      {{ $_ := set $objectData "type" ($objectData.type | default $.Values.fallbackDefaults.persistenceType) }}

      {{/* Perform general validations */}}
      {{- include "ix.v1.common.lib.persistence.validation" (dict "rootCtx" $ "objectData" $objectData) -}}

      {{/* Only spawn PVC if it's enabled and type of "pvc" */}}
      {{- if eq "pvc" $objectData.type -}}

        {{- $objectName := (printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $) $name) -}}
        {{/* Perform validations */}}
        {{- include "ix.v1.common.lib.chart.names.validation" (dict "name" $objectName) -}}

        {{/* Set the name of the secret */}}
        {{- $_ := set $objectData "name" $objectName -}}
        {{- $_ := set $objectData "shortName" $name -}}

        {{/* Call class to create the object */}}
        {{- include "ix.v1.common.class.pvc" (dict "rootCtx" $ "objectData" $objectData) -}}

      {{- end -}}
    {{- end -}}

  {{- end -}}

{{- end -}}
