{{- define "pgadmin.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.pgadminStorage.config) | nindent 4 }}
    targetSelector:
      pgadmin:
        pgadmin:
          mountPath: /var/lib/pgadmin
        {{- if and (eq .Values.pgadminStorage.config.type "ixVolume")
                  (not (.Values.pgadminStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/pgadmin
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      pgadmin:
        pgadmin:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.pgadminStorage.additionalStorages }}
  {{ printf "pgadmin-%v" (int $idx) }}:
    {{- $size := "" -}}
    {{- if $storage.size -}}
      {{- $size = (printf "%vGi" $storage.size) -}}
    {{- end }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      pgadmin:
        pgadmin:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{- if .Values.pgadminNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: pgadmin-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: server.key
      - key: tls.crt
        path: server.cert
    targetSelector:
      pgadmin:
        pgadmin:
          mountPath: /certs
          readOnly: true

scaleCertificate:
  pgadmin-cert:
    enabled: true
    id: {{ .Values.pgadminNetwork.certificateID }}
  {{- end }}
{{- end -}}
