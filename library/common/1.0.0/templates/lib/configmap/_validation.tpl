{{/* Configmap Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.configmap.validation" (dict "objectData" $objectData) -}}
objectData:
  name: The name of the configmap.
  labels: The labels of the configmap.
  annotations: The annotations of the configmap.
  data: The data of the configmap.
*/}}

{{- define "ix.v1.common.lib.configmap.validation" -}}
  {{- $objectData := .objectData -}}

  {{- if not $objectData.data -}}
    {{- fail "ConfigMap - Expected non-empty <data>" -}}
  {{- end -}}

  {{- if not (kindIs "map" $objectData.data) -}}
    {{- fail (printf "ConfigMap - Expected <data> to be a dictionary, but got [%v]" (kindOf $objectData.data)) -}}
  {{- end -}}

  {{- if and $objectData.labels (not (kindIs "map" $objectData.labels)) -}}
    {{- fail (printf "ConfigMap - Expected <labels> to be a dictionary, but got [%v]" (kindOf $objectData.labels)) -}}
  {{- end -}}

  {{- if and $objectData.annotations (not (kindIs "map" $objectData.annotations)) -}}
    {{- fail (printf "ConfigMap - Expected <annotations> to be a dictionary, but got [%v]" (kindOf $objectData.annotations)) -}}
  {{- end -}}

{{- end -}}
