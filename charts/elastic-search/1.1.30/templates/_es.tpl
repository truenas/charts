{{- define "es.workload" -}}
workload:
  es:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.esNetwork.hostNetwork }}
      containers:
        es:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.esRunAs.user }}
            runAsGroup: {{ .Values.esRunAs.group }}
            readOnlyRootFilesystem: false
          env:
            {{/* https://www.elastic.co/guide/en/elasticsearch/reference/master/docker.html#docker-configuration-methods */}}
            ES_HEAP_SIZE: {{ .Values.esConfig.heapSize }}
            ELASTIC_PASSWORD: {{ .Values.esConfig.password }}
            ES_SETTING_HTTP_PORT: {{ .Values.esNetwork.httpPort }}
            ES_SETTING_NODE_NAME: {{ .Values.esConfig.nodeName }}
            ES_SETTING_DISCOVERY_TYPE: single-node
            ES_SETTING_XPACK_SECURITY_ENABLED: true
            {{/* Transport is not used on single nodes */}}
            ES_SETTING_XPACK_SECURITY_TRANSPORT_SSL_ENABLED: false
            {{ if .Values.esNetwork.certificateID }}
            ES_SETTING_XPACK_SECURITY_HTTP_SSL_ENABLED: true
            ES_SETTING_XPACK_SECURITY_HTTP_SSL_KEY: /usr/share/elasticsearch/config/certs/tls.key
            ES_SETTING_XPACK_SECURITY_HTTP_SSL_CERTIFICATE: /usr/share/elasticsearch/config/certs/tls.crt
            ES_SETTING_XPACK_SECURITY_HTTP_SSL_CERTIFICATE__AUTHORITIES: /usr/share/elasticsearch/config/certs/ca.crt
            {{ end }}
          {{ with .Values.esConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: {{ include "es.schema" . }}
              path: /_cluster/health?local=true
              port: {{ .Values.esNetwork.httpPort }}
              httpHeaders:
                Authorization: Basic {{ printf "elastic:%s" .Values.esConfig.password | b64enc }}
            readiness:
              enabled: true
              type: {{ include "es.schema" . }}
              path: /_cluster/health?local=true
              port: {{ .Values.esNetwork.httpPort }}
              httpHeaders:
                Authorization: Basic {{ printf "elastic:%s" .Values.esConfig.password | b64enc }}
            startup:
              enabled: true
              type: {{ include "es.schema" . }}
              path: /_cluster/health?local=true
              port: {{ .Values.esNetwork.httpPort }}
              httpHeaders:
                Authorization: Basic {{ printf "elastic:%s" .Values.esConfig.password | b64enc }}
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.esRunAs.user
                                                        "GID" .Values.esRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{/* Service */}}
service:
  es:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: es
    ports:
      http:
        enabled: true
        primary: true
        port: {{ .Values.esNetwork.httpPort }}
        nodePort: {{ .Values.esNetwork.httpPort }}
        targetSelector: es

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.esStorage.data) | nindent 4 }}
    targetSelector:
      es:
        es:
          mountPath: /usr/share/elasticsearch/data
        {{- if and (eq .Values.esStorage.data.type "ixVolume")
                  (not (.Values.esStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}

  {{- range $idx, $storage := .Values.esStorage.additionalStorages }}
  {{ printf "es-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      es:
        es:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{- if .Values.esNetwork.certificateID }}
  certs:
    enabled: true
    type: secret
    objectName: es-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: tls.key
      - key: tls.crt
        path: tls.crt
      - key: tls.crt
        path: ca.crt
    targetSelector:
      es:
        es:
          mountPath: /usr/share/elasticsearch/config/certs
          readOnly: true

scaleCertificate:
  es-cert:
    enabled: true
    id: {{ .Values.esNetwork.certificateID }}
    {{- end -}}
{{- end -}}
