{{- define "linkding.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "linkding.storage.ci.migration" (dict "storage" .Values.linkdingStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.linkdingStorage.data) | nindent 4 }}
    targetSelector:
      linkding:
        linkding:
          mountPath: /etc/linkding/data
  secret:
    enabled: true
    type: secret
    objectName: linkding-secret
    defaultMode: "0600"
    targetSelector:
      linkding:
        linkding:
          mountPath: /etc/linkding/secretkey.txt
          subPath: secretkey.txt
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      linkding:
        linkding:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.linkdingStorage.additionalStorages }}
  {{ printf "linkding-%v:" (int $idx) }}
    enabled: true
    {{- include "linkding.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      linkding:
        linkding:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- include "linkding.storage.ci.migration" (dict "storage" .Values.linkdingStorage.pgData) }}
  {{- include "linkding.storage.ci.migration" (dict "storage" .Values.linkdingStorage.pgBackup) }}
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.linkdingStorage.pgData
            "pgBackup" .Values.linkdingStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "linkding.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
