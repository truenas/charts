{{/* SMB CSI */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.storage.smbCSI" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData:
  driver: The name of the driver.
  server: The server address.
  share: The share to the SMB share.
*/}}
{{- define "ix.v1.common.lib.storage.smbCSI" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}
csi:
  driver: {{ $objectData.driver }}
  {{- /* Create a unique handle, server/share#release-app-volumeName */}}
  volumeHandle: {{ printf "%s/%s#%s" $objectData.server $objectData.share $objectData.name }}
  volumeAttributes:
    source: {{ printf "//%v/%v" (tpl $objectData.server $rootCtx) (tpl $objectData.share $rootCtx) }}
  nodeStageSecretRef:
    name: {{ $objectData.name }}
    namespace: {{ $rootCtx.Release.Namespace }}
{{- end -}}
