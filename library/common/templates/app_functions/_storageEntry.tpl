{{/* This is a shim generating yaml that will be passed
    to the actual templates later on the process.
    For that reason the validation is minimal as the
    actual templates will do the validation. */}}
{{/* Call this template:
{{ include "ix.v1.common.app.storageOptions" (dict "storage" $storage) }}
*/}}
{{- define "ix.v1.common.app.storageOptions" -}}
  {{- $storage := .storage -}}

  {{- $size := "" -}}
  {{- $hostPath := "" -}}
  {{- $datasetName := "" -}}
  {{- $readOnly := false -}}
  {{- $server := "" -}}
  {{- $share := "" -}}
  {{- $domain := "" -}}
  {{- $username := "" -}}
  {{- $password := "" -}}

  {{- if $storage.readOnly -}}
    {{- $readOnly = true -}}
  {{- end -}}

  {{/* hostPath */}}
  {{- if eq $storage.type "hostPath" -}}
    {{- if not $storage.hostPathConfig -}}
      {{- fail (printf "Storage Shim - Expected non-empty [hostPathConfig]") -}}
    {{- end -}}

    {{- if $storage.hostPathConfig.aclEnable -}}
      {{- $hostPath = $storage.hostPathConfig.acl.path -}}
    {{- else -}}
      {{- $hostPath = $storage.hostPathConfig.hostPath -}}
    {{- end -}}
  {{- end -}}

  {{/* ixVolume */}}
  {{- if eq $storage.type "ixVolume" -}}
    {{- if not $storage.ixVolumeConfig -}}
      {{- fail (printf "Storage Shim - Expected non-empty [ixVolumeConfig]") -}}
    {{- end -}}

    {{- $datasetName = $storage.ixVolumeConfig.datasetName -}}
  {{- end -}}

  {{/* SMB Share */}}
  {{- if eq $storage.type "smb-pv-pvc" -}}
    {{- if not $storage.smbConfig -}}
      {{- fail (printf "Storage Shim - Expected non-empty [smbConfig]") -}}
    {{- end -}}

    {{- $server = $storage.smbConfig.server -}}
    {{- $share = $storage.smbConfig.share -}}
    {{- $domain = $storage.smbConfig.domain -}}
    {{- $username = $storage.smbConfig.username -}}
    {{- $password = $storage.smbConfig.password -}}
    {{- if $storage.smbConfig.size -}}
      {{- $size = (printf "%vGi" $storage.smbConfig.size) -}}
    {{- end -}}
  {{- end }}

  type: {{ $storage.type }}
  size: {{ $size }}
  hostPath: {{ $hostPath }}
  datasetName: {{ $datasetName }}
  readOnly: {{ $readOnly }}
  server: {{ $server }}
  share: {{ $share }}
  domain: {{ $domain }}
  username: {{ $username }}
  password: {{ $password }}
  {{- if eq $storage.type "smb-pv-pvc" }}
  mountOptions:
    - key: noperm
  {{- end }}
{{- end -}}
