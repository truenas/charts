{{/* Certificate Spawwner */}}
{{/* Call this template:
{{ include "ix.v1.common.spawner.certificate" $ -}}
*/}}

{{- define "ix.v1.common.spawner.certificate" -}}

  {{- range $name, $certificate := .Values.scaleCertificate -}}

    {{- if $certificate.enabled -}}

      {{/* Create a copy of the certificate */}}
      {{- $objectData := (mustDeepCopy $certificate) -}}

      {{- $objectName := (printf "%s-%s" (include "ix.v1.common.lib.chart.names.fullname" $) $name) -}}
      {{/* Perform validations */}}
      {{- include "ix.v1.common.lib.chart.names.validation" (dict "name" $objectName) -}}
      {{- include "ix.v1.common.lib.certificate.validation" (dict "objectData" $objectData) -}}
      {{- include "ix.v1.common.lib.metadata.validation" (dict "objectData" $objectData "caller" "Certificate") -}}

      {{/* Prepare data */}}
      {{- $data := fromJson (include "ix.v1.common.lib.certificate.getData" (dict "rootCtx" $ "objectData" $objectData)) -}}
      {{- $_ := set $objectData "data" $data -}}

      {{/* Set the type to certificate */}}
      {{- $_ := set $objectData "type" "certificate" -}}

      {{/* Set the name of the certificate */}}
      {{- $_ := set $objectData "name" $objectName -}}
      {{- $_ := set $objectData "shortName" $name -}}

      {{/* Call class to create the object */}}
      {{- include "ix.v1.common.class.secret" (dict "rootCtx" $ "objectData" $objectData) -}}

    {{- end -}}

  {{- end -}}

{{- end -}}
