{{- define "roundcube.persistence" -}}
persistence:
  html:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.roundcubeStorage.html) | nindent 4 }}
    targetSelector:
      roundcube:
        roundcube:
          mountPath: /var/www/html
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.roundcubeStorage.config) | nindent 4 }}
    targetSelector:
      roundcube:
        roundcube:
          mountPath: /var/roundcube/config
  temps:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.roundcubeStorage.temps) | nindent 4 }}
    targetSelector:
      roundcube:
        roundcube:
          mountPath: /tmp/roundcube-temp
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      roundcube:
        roundcube:
          mountPath: /tmp

  {{- range $idx, $storage := .Values.roundcubeStorage.additionalStorages }}
  {{ printf "roundcube-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      roundcube:
        roundcube:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.roundcubeStorage.pgData
            "pgBackup" .Values.roundcubeStorage.pgBackup
      ) | nindent 2 }}

{{- end -}}
