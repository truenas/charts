{{/* SMB CSI */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.storage.smbCSI" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData:
  driver: The name of the driver.
  server: The server address.
  path: The path to the SMB share.
*/}}
{{- define "ix.v1.common.lib.storage.smbCSI" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}
csi:
  driver: {{ $objectData.driver }}
  volumeHandle:
  volumeAttributes:
    source: {{ printf "%v/%v" (tpl $objectData.server $rootCtx) (tpl $objectData.path $rootCtx) }}
  nodeStageSecretRef:
    name: # TODO:
    namespace: {{ $rootCtx.Release.Namespace }}
{{- end -}}
