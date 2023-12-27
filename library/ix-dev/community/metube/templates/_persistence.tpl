{{- define "metube.persistence" -}}
persistence:
  downloads:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.metubeStorage.downloads) | nindent 4 }}
    targetSelector:
      metube:
        metube:
          mountPath: /downloads
        {{- if and (eq .Values.metubeStorage.downloads.type "ixVolume")
                  (not (.Values.metubeStorage.downloads.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/downloads
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      metube:
        metube:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.metubeStorage.additionalStorages }}
  {{ printf "metube-%v" (int $idx) }}:
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    enabled: true
    targetSelector:
      metube:
        metube:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
