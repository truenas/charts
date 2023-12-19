{{- define "linkding.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.linkdingStorage.data) | nindent 4 }}
    targetSelector:
      linkding:
        linkding:
          mountPath: /etc/linkding/data
        {{- if and (eq .Values.linkdingStorage.data.type "ixVolume")
                  (not (.Values.linkdingStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
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
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      linkding:
        linkding:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.linkdingStorage.pgData
            "pgBackup" .Values.linkdingStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
