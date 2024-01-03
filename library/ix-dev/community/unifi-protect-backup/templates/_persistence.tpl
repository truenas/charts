{{- define "upb.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "upb.storage.ci.migration" (dict "storage" .Values.upbStorage.config) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.upbStorage.config) | nindent 4 }}
    targetSelector:
      unifi-protect:
        unifi-protect:
          mountPath: /config
  data:
    enabled: true
    {{- include "upb.storage.ci.migration" (dict "storage" .Values.upbStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.upbStorage.data) | nindent 4 }}
    targetSelector:
      unifi-protect:
        unifi-protect:
          mountPath: /data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      unifi-protect:
        unifi-protect:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.upbStorage.additionalStorages }}
  {{ printf "upb-%v" (int $idx) }}:
    enabled: true
    {{- include "upb.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      unifi-protect:
        unifi-protect:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "upb.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
