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
  {{- $medium := "" -}}
  {{- $mountOpts := (list
      (dict "key" "noperm")
  ) -}}

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

    {{- $server = $storage.smbConfig.server | quote -}}
    {{- $share = $storage.smbConfig.share | quote -}}
    {{- $domain = $storage.smbConfig.domain | quote -}}
    {{- $username = $storage.smbConfig.username | quote -}}
    {{- $password = $storage.smbConfig.password | quote -}}
    {{- if $storage.smbConfig.mountOptions -}}
      {{- $mountOpts = $storage.smbConfig.mountOptions -}}
    {{- end -}}
    {{- if $storage.smbConfig.size -}}
      {{- $size = (printf "%vGi" $storage.smbConfig.size) -}}
    {{- end -}}
  {{- end -}}

  {{/* emptyDir */}}
  {{- if eq $storage.type "emptyDir" -}}
    {{- if not $storage.emptyDirConfig -}}
      {{- fail (printf "Storage Shim - Expected non-empty [emptyDirConfig]") -}}
    {{- end -}}

    {{- if $storage.emptyDirConfig.medium -}}
      {{- $medium = $storage.emptyDirConfig.medium -}}
    {{- end -}}

    {{- if $storage.emptyDirConfig.size -}}
      {{- $size = (printf "%vGi" $storage.emptyDirConfig.size) -}}
    {{- end -}}
  {{- end }}

type: {{ $storage.type }}
size: {{ $size }}
hostPath: {{ $hostPath }}
datasetName: {{ $datasetName }}
readOnly: {{ $readOnly }}
medium: {{ $medium }}
server: {{ $server }}
share: {{ $share }}
domain: {{ $domain }}
username: {{ $username }}
password: {{ $password }}
{{- if eq $storage.type "smb-pv-pvc" }}
mountOptions: {{ $mountOpts | toYaml | nindent 2 }}
{{- end }}
{{- end -}}
