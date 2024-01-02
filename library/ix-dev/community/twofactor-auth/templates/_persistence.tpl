{{- define "twofauth.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "twofauth.storage.ci.migration" (dict "storage" .Values.twofauthStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.twofauthStorage.config) | nindent 4 }}
    targetSelector:
      twofauth:
        twofauth:
          mountPath: /2fauth
        {{- if and (eq .Values.twofauthStorage.config.type "ixVolume")
                  (not (.Values.twofauthStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/2fauth
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      twofauth:
        twofauth:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.twofauthStorage.additionalStorages }}
  {{ printf "twofauth-%v" (int $idx) }}:
    enabled: true
    {{- include "twofauth.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      twofauth:
        twofauth:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "twofauth.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
