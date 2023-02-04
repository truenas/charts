{{/* Service - MetalLB Annotations */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.metalLBAnnotations" (dict "rootCtx" $rootCtx "annotations" $annotations) -}}
rootCtx: The root context of the service
*/}}

{{- define "ix.v1.common.lib.service.metalLBAnnotations" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $annotations := .annotations -}}

  {{- $sharedKey := include "ix.v1.common.lib.chart.names.fullname" $rootCtx -}}

  {{- if $rootCtx.Values.global.addMetalLBAnnotations -}}
    {{- $_ := set $annotations "metallb.universe.tf/allow-shared-ip" $sharedKey -}}
  {{- end -}}
{{- end -}}

{{/* Service - Traefik Annotations */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.traefikAnnotations" (dict "rootCtx" $rootCtx "annotations" $annotations) -}}
rootCtx: The root context of the service
*/}}

{{- define "ix.v1.common.lib.service.traefikAnnotations" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $annotations := .annotations -}}

  {{- if $rootCtx.Values.global.addTraefikAnnotations -}}
    {{- $_ := set $annotations "traefik.ingress.kubernetes.io/service.serversscheme" "https" -}}
  {{- end -}}
{{- end -}}
