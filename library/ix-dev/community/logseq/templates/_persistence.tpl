{{- define "logseq.persistence" -}}
persistence:
  nginx:
    enabled: true
    type: configmap
    objectName: nginx-config
    defaultMode: "0600"
    targetSelector:
      logseq:
        logseq:
          mountPath: /etc/nginx/conf.d/default.conf
          subPath: nginx.conf
          readOnly: true
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      logseq:
        logseq:
          mountPath: /tmp
  varcache:
    enabled: true
    type: emptyDir
    targetSelector:
      logseq:
        logseq:
          mountPath: /var/cache/nginx
  varrun:
    enabled: true
    type: emptyDir
    targetSelector:
      logseq:
        logseq:
          mountPath: /var/run
  {{- range $idx, $storage := .Values.logseqStorage.additionalStorages }}
  {{ printf "logseq-%v" (int $idx) }}:
    enabled: true
    {{- include "logseq.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      logseq:
        logseq:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end -}}

  {{- if .Values.logseqNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: logseq-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: tls.key
      - key: tls.crt
        path: tls.crt
    targetSelector:
      logseq:
        logseq:
          mountPath: /etc/nginx/certs
          readOnly: true

scaleCertificate:
  logseq-cert:
    enabled: true
    id: {{ .Values.logseqNetwork.certificateID }}
    {{- end -}}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "logseq.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
