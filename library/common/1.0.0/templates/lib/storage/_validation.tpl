{{/* PVC Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.persistence.validation" (dict "objectData" $objectData) -}}
objectData:
  rootCtx: The root context.
  objectData: The service object.
*/}}

{{- define "ix.v1.common.lib.persistence.validation" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- if and $objectData.labels (not (kindIs "map" $objectData.labels)) -}}
    {{- fail (printf "Persistence - Expected <labels> to be a dictionary, but got [%v]" (kindOf $objectData.labels)) -}}
  {{- end -}}

  {{- if and $objectData.annotations (not (kindIs "map" $objectData.annotations)) -}}
    {{- fail (printf "Persistence - Expected <annotations> to be a dictionary, but got [%v]" (kindOf $objectData.annotations)) -}}
  {{- end -}}

  {{- $types := (list "pvc" "emptyDir" "nfs" "hostPath" "ixVolume" "secret" "configmap") -}}
  {{- if not (mustHas $objectData.type $types) -}}
    {{- fail (printf "Persistence - Expected <type> to be one of [%s], but got [%s]" (join ", " $types) $objectData.type) -}}
  {{- end -}}

  {{- if and $objectData.targetSelector (not (kindIs "map" $objectData.targetSelector)) -}}
    {{- fail (printf "Persistence - Expected <targetSelector> to be [dict], but got [%s]" (kindOf $objectData.targetSelector)) -}}
  {{- end -}}

{{- end -}}
