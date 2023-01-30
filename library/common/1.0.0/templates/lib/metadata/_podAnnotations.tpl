{{/* Labels that are added to podSpec */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.metadata.podAnnotations" $ }}
*/}}
{{- define "ix.v1.common.lib.metadata.podAnnotations" -}}
rollme: {{ randAlphaNum 5 | quote }}
  {{- if and .Values.ixExternalInterfacesConfiguration -}}
    {{- if .Values.ixExternalInterfacesConfigurationNames }}
k8s.v1.cni.cncf.io/networks: {{ join ", " .Values.ixExternalInterfacesConfigurationNames }}
    {{- else -}}
      {{- fail "External interfaces defined, but <ixExteernalInterfaceConfigurationNames> is empty." -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
