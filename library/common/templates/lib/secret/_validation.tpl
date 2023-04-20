{{/* Secret Validation */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.secret.validation" (dict "objectData" $objectData) -}}
objectData:
  labels: The labels of the secret.
  annotations: The annotations of the secret.
  data: The data of the secret.
*/}}

{{- define "ix.v1.common.lib.secret.validation" -}}
  {{- $objectData := .objectData -}}

  {{- if not $objectData.data -}}
    {{- fail "Secret - Expected non-empty <data>" -}}
  {{- end -}}

  {{- if not (kindIs "map" $objectData.data) -}}
    {{- fail (printf "Secret - Expected <data> to be a dictionary, but got [%v]" (kindOf $objectData.data)) -}}
  {{- end -}}

  {{- if and (hasKey $objectData "type") (not $objectData.type) -}}
    {{- fail (printf "Secret - Found <type> key, but it's empty") -}}
  {{- end -}}

{{- end -}}
