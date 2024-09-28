{{- define "navidrome.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.navidromeStorage.data) | nindent 4 }}
    targetSelector:
      navidrome:
        navidrome:
          mountPath: /data
        {{- if and (eq .Values.navidromeStorage.data.type "ixVolume")
                  (not (.Values.navidromeStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  music:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.navidromeStorage.music) | nindent 4 }}
    targetSelector:
      navidrome:
        navidrome:
          mountPath: /music
        {{- if and (eq .Values.navidromeStorage.music.type "ixVolume")
                  (not (.Values.navidromeStorage.music.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/music
        {{- end }}
  {{- if .Values.navidromeConfig.localPlayback }}
  snd-device:
    enabled: true
    type: hostPath
    hostPath: /dev/snd
    targetSelector:
      navidrome:
        navidrome:
          mountPath: /dev/snd
  {{- end }}
  {{- range $idx, $storage := .Values.navidromeStorage.additionalStorages }}
  {{ printf "navidrome-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      navidrome:
        navidrome:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
