{{- define "transmission.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "transmission.storage.ci.migration" (dict "storage" .Values.transmissionStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.transmissionStorage.config) | nindent 4 }}
    targetSelector:
      transmission:
        transmission:
          mountPath: /config
        {{- if and (eq .Values.transmissionStorage.config.type "ixVolume")
                  (not (.Values.transmissionStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end -}}
  download-complete:
    enabled: true
    {{- include "transmission.storage.ci.migration" (dict "storage" .Values.transmissionStorage.downloadsComplete) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.transmissionStorage.downloadsComplete) | nindent 4 }}
    targetSelector:
      transmission:
        transmission:
          mountPath: {{ .Values.transmissionStorage.downloadsDir | default "/downloads/complete" }}
        {{- if and (eq .Values.transmissionStorage.downloadsComplete.type "ixVolume")
                  (not (.Values.transmissionStorage.downloadsComplete.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/complete
        {{- end -}}
  {{- if .Values.transmissionStorage.enableIncompleteDir }}
  download-incomplete:
    enabled: true
    {{- include "transmission.storage.ci.migration" (dict "storage" .Values.transmissionStorage.downloadsIncomplete) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.transmissionStorage.downloadsIncomplete) | nindent 4 }}
    targetSelector:
      transmission:
        transmission:
          mountPath: {{ .Values.transmissionStorage.incompleteDir | default "/downloads/incomplete" }}
        {{- if and (eq .Values.transmissionStorage.downloadsIncomplete.type "ixVolume")
                  (not (.Values.transmissionStorage.downloadsIncomplete.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/incomplete
        {{- end -}}
  {{- end -}}
  {{- range $idx, $storage := .Values.transmissionStorage.additionalStorages }}
  {{ printf "transmission-%v:" (int $idx) }}
    enabled: true
    {{- include "transmission.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      transmission:
        transmission:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.3.0+ */}}
{{- define "transmission.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
