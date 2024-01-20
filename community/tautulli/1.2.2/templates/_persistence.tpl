{{- define "tautulli.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "tautulli.storage.ci.migration" (dict "storage" .Values.tautulliStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.tautulliStorage.config) | nindent 4 }}
    targetSelector:
      tautulli:
        tautulli:
          mountPath: /config
        {{- if and (eq .Values.tautulliStorage.config.type "ixVolume")
                  (not (.Values.tautulliStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      tautulli:
        tautulli:
          mountPath: /tmp

  {{- range $idx, $storage := .Values.tautulliStorage.additionalStorages }}
  {{ printf "tautulli-%v" (int $idx) }}:
    enabled: true
    {{- include "tautulli.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      tautulli:
        tautulli:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "tautulli.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
