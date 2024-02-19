{{- define "pihole.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.piholeStorage.config) | nindent 4 }}
    targetSelector:
      pihole:
        pihole:
          mountPath: /etc/pihole
  dnsmasq:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.piholeStorage.dnsmasq) | nindent 4 }}
    targetSelector:
      pihole:
        pihole:
          mountPath: /etc/dnsmasq.d
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      pihole:
        pihole:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.piholeStorage.additionalStorages }}
  {{ printf "pihole-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      pihole:
        pihole:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
