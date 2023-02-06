{{/* Service Class */}}
{{/* Call this template:
{{ include "ix.v1.common.class.service" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the template. It is used to access the global context.
objectData: The service data, that will be used to render the Service object.
*/}}

{{- define "ix.v1.common.class.service" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $svcType := $objectData.type | default $rootCtx.Values.fallbackDefaults.serviceType -}}

  {{/* Init variables */}}
  {{- $hasHTTPSPort := false -}}
  {{- $hasHostPort := false -}}
  {{- $hostNetwork := false -}}
  {{- $podValues := dict -}}

  {{- $specialTypes := (list "ExternalName" "ExternalIP") -}}
  {{/* External Name / External IP does not rely on any pod values */}}
  {{- if not (mustHas $svcType $specialTypes) -}}
    {{/* Get Pod Values based on the selector (or the absence of it) */}}
    {{- $podValues = fromJson (include "ix.v1.common.lib.service.getSelectedPodValues" (dict "rootCtx" $rootCtx "objectData" $objectData)) -}}

    {{/* Get Pod hostNetwork configuration */}}
    {{- $hostNetwork = include "ix.v1.common.lib.pod.hostNetwork" (dict "rootCtx" $rootCtx "objectData" $podValues) -}}

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

    {{/* When hostNetwork is set on the pod, force ClusterIP, so services wont try to bind the same ports on the host */}}
    {{- if or (and (kindIs "bool" $hostNetwork) $hostNetwork) (and (kindIs "string" $hostNetwork) (eq $hostNetwork "true")) -}}
      {{- $svcType = "ClusterIP" -}}
    {{- end -}}

    {{/* When hostPort is defined, force ClusterIP aswell */}}
    {{- if $hasHostPort -}}
      {{- $svcType = "ClusterIP" -}}
    {{- end -}}
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
  {{- if $hasHTTPSPort -}}
    {{- include "ix.v1.common.lib.service.traefikAnnotations" (dict "rootCtx" $rootCtx "annotations" $annotations) -}}
  {{- end -}}
  {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  {{- if eq $svcType "ClusterIP" -}}
    {{- include "ix.v1.common.lib.service.spec.clusterIP" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 -}}
  {{- else if eq $svcType "LoadBalancer" -}}
    {{- include "ix.v1.common.lib.service.spec.loadBalancer" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 -}}
  {{- else if eq $svcType "NodePort" -}}
    {{- include "ix.v1.common.lib.service.spec.nodePort" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 -}}
  {{- else if eq $svcType "ExternalName" -}}
    {{- include "ix.v1.common.lib.service.spec.externalName" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 -}}
  {{- else if eq $svcType "ExternalIP" -}}
    {{- include "ix.v1.common.lib.service.spec.externalIP" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 -}}
  {{- end -}}
  {{- with (include "ix.v1.common.lib.service.ports" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim) }}
  ports:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- if not (mustHas $svcType $specialTypes) }}
  selector:
    {{- include "ix.v1.common.lib.metadata.selectorLabels" (dict "rootCtx" $rootCtx "podName" $podValues.shortName) | trim | nindent 4 -}}
  {{- end -}}
  {{- if eq $svcType "ExternalIP" -}}
    {{- include "ix.v1.common.class.endpointSlice" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 0 }}
  {{- end -}}
{{- end -}}
