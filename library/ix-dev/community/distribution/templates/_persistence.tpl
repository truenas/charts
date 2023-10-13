{{- define "distribution.persistence" -}}
persistence:
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

#   {{- if .Values.distributionNetwork.certificateID }}
#   cert:
#     enabled: true
#     type: secret
#     objectName: distribution-cert
#     defaultMode: "0600"
#     items:
#       - key: tls.key
#         path: tls.key
#       - key: tls.crt
#         path: tls.crt
#     targetSelector:
#       distribution:
#         distribution:
#           mountPath: /etc/nginx/certs
#           readOnly: true

# scaleCertificate:
#   distribution-cert:
#     enabled: true
#     id: {{ .Values.distributionNetwork.certificateID }}
#     {{- end -}}
{{- end -}}
