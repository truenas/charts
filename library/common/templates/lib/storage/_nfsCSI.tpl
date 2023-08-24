{{/* NFS CSI */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.storage.nfsCSI" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the chart.
objectData:
  driver: The name of the driver.
  server: The server address.
  share: The share to the NFS share.
*/}}
{{- define "ix.v1.common.lib.storage.nfsCSI" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}
csi:
  driver: {{ $objectData.driver }}
  {{- /* Create a unique handle, server/share#release-app-volumeName */}}
  volumeHandle: {{ printf "%s%s#%s" $objectData.server $objectData.share $objectData.name }}
  volumeAttributes:
    server: {{ tpl $objectData.server $rootCtx }}
    share: {{ tpl $objectData.share $rootCtx }}
{{- end -}}
