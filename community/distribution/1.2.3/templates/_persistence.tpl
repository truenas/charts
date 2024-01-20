{{- define "distribution.persistence" -}}
persistence:
  {{- if .Values.distributionStorage.useFilesystemBackend }}
  data:
    enabled: true
    {{- include "distribution.storage.ci.migration" (dict "storage" .Values.distributionStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.distributionStorage.data) | nindent 4 }}
    targetSelector:
      distribution:
        distribution:
          mountPath: /var/lib/registry
        {{- if and (eq .Values.distributionStorage.data.type "ixVolume")
                  (not (.Values.distributionStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/registry
        {{- end -}}
  {{- end }}

  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      distribution:
        distribution:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.distributionStorage.additionalStorages }}
  {{ printf "distribution-%v:" (int $idx) }}
    enabled: true
    {{- include "distribution.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      distribution:
        distribution:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end -}}

  {{- if .Values.distributionConfig.basicAuthUsers }}
  htpasswd:
    enabled: true
    type: secret
    objectName: distribution-htpasswd
    defaultMode: "0600"
    items:
      - key: htpasswd
        path: htpasswd
    targetSelector:
      distribution:
        distribution:
          mountPath: /auth
          readOnly: true
  {{- end -}}

  {{- if .Values.distributionNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: distribution-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: tls.key
      - key: tls.crt
        path: tls.crt
    targetSelector:
      distribution:
        distribution:
          mountPath: /certs
          readOnly: true

scaleCertificate:
  distribution-cert:
    enabled: true
    id: {{ .Values.distributionNetwork.certificateID }}
    {{- end -}}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "distribution.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
