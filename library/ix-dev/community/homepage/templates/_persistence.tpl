{{- define "homepage.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "homepage.storage.ci.migration" (dict "storage" .Values.homepageStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.homepageStorage.config) | nindent 4 }}
    targetSelector:
      homepage:
        homepage:
          mountPath: /app/config
          mountPath: /var/lib/grafana
        {{- if and (eq .Values.homepageStorage.config.type "ixVolume")
                  (not (.Values.homepageStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      homepage:
        homepage:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.homepageStorage.additionalStorages }}
  {{ printf "homepage-%v:" (int $idx) }}
    {{- include "homepage.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    enabled: true
    targetSelector:
      homepage:
        homepage:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "homepage.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
