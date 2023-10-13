{{- define "distribution.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.distributionStorage.data.type }}
    datasetName: {{ .Values.distributionStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.distributionStorage.data.hostPath | default "" }}
    targetSelector:
      distribution:
        distribution:
          mountPath: /var/lib/registry
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      distribution:
        distribution:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.distributionStorage.additionalStorages }}
  {{ printf "distribution-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      distribution:
        distribution:
          mountPath: {{ $storage.mountPath }}
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
