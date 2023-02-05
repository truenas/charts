{{/* Service Class */}}
{{/* Call this template:
{{ include "ix.v1.common.class.service" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the template. It is used to access the global context.
objectData: The service data, that will be used to render the Service object.
*/}}

{{- define "ix.v1.common.class.service" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $svcType := $objectData.type | default "ClusterIP" -}}

  {{/* Get Pod Values based on the selector (or the absence of it) */}}
  {{/* TODO: handle caes that svcType does not need a pod to link with */}}
  {{- $podValues := fromJson (include "ix.v1.common.lib.service.getSelectedPodValues" (dict "rootCtx" $rootCtx "objectData" $objectData)) -}}

  {{/* Get Pod's hostNetwork configuration */}}
  {{- $hostNetwork := include "ix.v1.common.lib.pod.hostNetwork" (dict "rootCtx" $rootCtx "objectData" $podValues) -}}

  {{- $hasHTTPSPort := false -}}
  {{- $hasHostPort := false -}}

  {{- range $portName, $port := $objectData.ports -}}
    {{- if $port.enabled -}}
      {{- if eq ($port.protocol | default "") "HTTPS" -}}
        {{- $hasHTTPSPort = true -}}
      {{- end -}}

      {{- if and (hasKey $port "hostPort") $port.hostPort -}}
        {{- $hasHostPort = true -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{/* When hostNetwork is set on the pod, force ClusterIP, so services won't try to bind the same ports on the host */}}
  {{- if or (and (kindIs "bool" $hostNetwork) $hostNetwork) (and (kindIs "string" $hostNetwork) (eq $hostNetwork "true")) -}}
    {{- $svcType = "ClusterIP" -}}
  {{- end -}}

  {{/* When hostPort is defined, force ClusterIP aswell */}}
  {{- if $hasHostPort -}}
    {{- $svcType = "ClusterIP" -}}
  {{- end }}

---
apiVersion: v1
kind: Service
metadata:
  name: {{ $objectData.name }}
  {{- $labels := (mustMerge ($objectData.labels | default dict) (include "ix.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- $annotations := (mustMerge ($objectData.annotations | default dict) (include "ix.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- if eq $svcType "LoadBalancer" -}}
    {{- include "ix.v1.common.lib.service.metalLBAnnotations" (dict "rootCtx" $rootCtx "objectData" $objectData "annotations" $annotations) -}}
  {{- end -}}
  {{- if and $hasHTTPSPort -}}
    {{- include "ix.v1.common.lib.service.traefikAnnotations" (dict "rootCtx" $rootCtx "annotations" $annotations) -}}
  {{- end -}}
  {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  {{- if eq $svcType "ClusterIP" -}}
    {{- include "ix.v1.common.lib.service.spec.clusterIP" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 }}
  {{- else if eq $svcType "LoadBalancer" -}}
    {{- include "ix.v1.common.lib.service.spec.loadBalancer" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 }}
  {{- else if eq $svcType "NodePort" -}}
    {{- include "ix.v1.common.lib.service.spec.nodePort" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 }}
  {{- else if eq $svcType "ExternalName" -}}
    {{- include "ix.v1.common.lib.service.spec.externalName" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 }}
  {{- else if eq $svcType "ExternalIP" -}}
    {{- include "ix.v1.common.lib.service.spec.externalIP" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 }}
  {{- end }}
  publishNotReadyAddresses: {{ include "ix.v1.common.lib.service.publishNotReadyAddresses" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim }}
  {{- with (include "ix.v1.common.lib.service.externalIPs" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim) }}
  externalIPs:
    {{- . | nindent 2 }}
  {{- end -}}
  {{/* TODO: sessionAffinity */}}

{{/* TODO: ports */}}
  {{- if not (mustHas $svcType (list "ExternalName" "ExternalIP")) }}
selector:
    {{- include "ix.v1.common.lib.metadata.selectorLabels" (dict "rootCtx" $rootCtx "podName" $podValues.shortName) | trim | nindent 2 }}
  {{- end -}}
{{/* TODO: endpoints */}}
{{- end -}}
