{{- define "rust.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.rustStorage.data.type }}
    datasetName: {{ .Values.rustStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.rustStorage.data.hostPath | default "" }}
    {{- include "rustdesk.storage.ci.migration" (dict "storage" .Values.rustStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.rustStorage.data) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: /root
        {{- if and (eq .Values.rustStorage.data.type "ixVolume")
                  (not (.Values.rustStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
      relay:
        relay:
          mountPath: /root

  {{- range $idx, $storage := .Values.rustStorage.additionalStorages }}
  {{ printf "rust-%v" (int $idx) }}:
    enabled: true
    {{- include "rustdesk.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      server:
        server:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
      relay:
        relay:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "rustdesk.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
