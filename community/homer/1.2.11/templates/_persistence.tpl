{{- define "homer.persistence" -}}
persistence:
  assets:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.homerStorage.assets) | nindent 4 }}
    targetSelector:
      homer:
        homer:
          mountPath: /www/assets
        {{- if and (eq .Values.homerStorage.assets.type "ixVolume")
                  (not (.Values.homerStorage.assets.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/assets
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      homer:
        homer:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.homerStorage.additionalStorages }}
  {{ printf "homer-%v" (int $idx) }}:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      homer:
        homer:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
