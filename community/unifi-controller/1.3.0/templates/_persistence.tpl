{{- define "unifi.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.unifiStorage.data) | nindent 4 }}
    targetSelector:
      unifi:
        unifi:
          mountPath: /usr/lib/unifi/data
        {{- if and (eq .Values.unifiStorage.data.type "ixVolume")
                  (not (.Values.unifiStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/unifi
        {{- end }}
        02-migrate:
          mountPath: /usr/lib/unifi/data
  cert:
    # Mounted secrets are combined
    # into a java keystore at startup
    enabled: true
    type: emptyDir
    targetSelector:
      unifi:
        unifi:
          mountPath: /usr/lib/unifi/cert
  logs:
    enabled: true
    type: emptyDir
    targetSelector:
      unifi:
        unifi:
          mountPath: /usr/lib/unifi/logs
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      unifi:
        unifi:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.unifiStorage.additionalStorages }}
  {{ printf "unifi-%v" (int $idx) }}:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      unifi:
        unifi:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end -}}

  {{- if .Values.unifiNetwork.certificateID }}
  cert-private:
    enabled: true
    type: secret
    objectName: unifi-cert
    defaultMode: "0600"
    targetSelector:
      unifi:
        unifi:
          mountPath: /usr/lib/unifi/cert/privkey.pem
          subPath: tls.key
          readOnly: true
  cert-public:
    enabled: true
    type: secret
    objectName: unifi-cert
    defaultMode: "0600"
    targetSelector:
      unifi:
        unifi:
          mountPath: /usr/lib/unifi/cert/cert.pem
          subPath: tls.crt
          readOnly: true
scaleCertificate:
  unifi-cert:
    enabled: true
    id: {{ .Values.unifiNetwork.certificateID }}
    {{- end -}}
{{- end -}}
