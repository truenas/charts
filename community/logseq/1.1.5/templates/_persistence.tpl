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
    {{- $size := "" -}}
    {{- if $storage.size -}}
      {{- $size = (printf "%vGi" $storage.size) -}}
    {{- end }}
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    server: {{ $storage.server | default "" }}
    share: {{ $storage.share | default "" }}
    domain: {{ $storage.domain | default "" }}
    username: {{ $storage.username | default "" }}
    password: {{ $storage.password | default "" }}
    size: {{ $size }}
    {{- if eq $storage.type "smb-pv-pvc" }}
    mountOptions:
      - key: noperm
    {{- end }}
    targetSelector:
      logseq:
        logseq:
          mountPath: {{ $storage.mountPath }}
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
