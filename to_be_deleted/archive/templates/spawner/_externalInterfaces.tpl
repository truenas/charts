{{- define "ix.v1.common.spawner.externalInterface" -}}
  {{/* Validate that data from externalInterfaces are correct before start creating objects */}}
  {{- range $iface := .Values.externalInterfaces -}}
    {{- include "ix.v1.common.externalInterface" (dict "iface" $iface) -}}
  {{- end -}}

  {{/* Now we are sure data is validated, spawn the objects */}}
  {{- range $index, $iface := .Values.ixExternalInterfacesConfiguration -}}
    {{- $values := dict -}}
    {{- $_ := set $values "iface" $iface -}}
    {{- $_ := set $values "index" $index -}}
    {{- include "ix.v1.common.class.externalInterface" (dict "values" $values "root" $) -}}
  {{- end -}}
{{- end -}}
