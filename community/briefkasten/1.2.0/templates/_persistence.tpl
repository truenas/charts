{{- define "briefkasten.persistence" -}}
persistence:
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      briefkasten:
        briefkasten:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.briefkastenStorage.additionalStorages }}
  {{ printf "briefkasten-%v:" (int $idx) }}
    enabled: true
    {{- include "briefkasten.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      briefkasten:
        briefkasten:
          mountPath: {{ $storage.mountPath }}
        {{- if eq $storage.type "ixVolume" }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end -}}

  {{- include "briefkasten.storage.ci.migration" (dict "storage" .Values.briefkastenStorage.pgData) }}
  {{- include "briefkasten.storage.ci.migration" (dict "storage" .Values.briefkastenStorage.pgBackup) }}
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.briefkastenStorage.pgData
            "pgBackup" .Values.briefkastenStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "briefkasten.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
