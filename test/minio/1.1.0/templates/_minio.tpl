{{- define "minio.workload" -}}
workload:
  minio:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ include "minio.hostnetwork" $ }}
      containers:
        minio:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.minioRunAs.user }}
            runAsGroup: {{ .Values.minioRunAs.group }}
          envFrom:
            - secretRef:
                name: minio-creds
          args:
            - server
            - "--address"
            - {{ printf ":%v" .Values.minioNetwork.apiPort | quote }}
            - "--console-address"
            - {{ printf ":%v" .Values.minioNetwork.webPort | quote }}
            {{- if .Values.minioNetwork.certificateID }}
            - "--certs-dir"
            - "/.minio/certs"
            {{- end -}}
            {{- if .Values.minioLogging.anonymous }}
            - "--anonymous"
            {{- end -}}
            {{- if .Values.minioLogging.quiet }}
            - "--quiet"
            {{- end }}
          probes:
            liveness:
              enabled: true
              type: {{ include "minio.scheme" $ }}
              port: "{{ .Values.minioNetwork.apiPort }}"
              path: /minio/health/live
            readiness:
              enabled: true
              type: {{ include "minio.scheme" $ }}
              port: "{{ .Values.minioNetwork.apiPort }}"
              path: /minio/health/live
            startup:
              enabled: true
              type: {{ include "minio.scheme" $ }}
              port: "{{ .Values.minioNetwork.apiPort }}"
              path: /minio/health/live
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.minioRunAs.user
                                                        "GID" .Values.minioRunAs.group
                                                        "type" "install") | nindent 8 -}}
      {{- if .Values.minioLogging.logsearch.enabled }}
        logsearch-wait:
          enabled: true
          type: init
          imageSelector: bashImage
          resources:
            limits:
              cpu: 500m
              memory: 256Mi
          envFrom:
            - secretRef:
                name: minio-creds
          command: bash
          args:
            - -c
            - |
              echo "Pinging Logsearch API for readiness..."
              until wget --spider --quiet --timeout=3 --tries=1 ${MINIO_LOG_QUERY_URL}/status; do
                echo "Waiting for Logsearch API (${MINIO_LOG_QUERY_URL}/status) to be ready..."
                sleep 2
              done
              echo "Logsearch API is ready"
      {{- end }}

{{/* Service */}}
service:
  minio:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: minio
    ports:
      api:
        enabled: true
        primary: true
        port: {{ .Values.minioNetwork.apiPort }}
        nodePort: {{ .Values.minioNetwork.apiPort }}
        targetSelector: minio
      webui:
        enabled: true
        port: {{ .Values.minioNetwork.webPort }}
        nodePort: {{ .Values.minioNetwork.webPort }}
        targetSelector: minio

{{/* Persistence */}}
persistence:
  {{- range $idx, $storage := .Values.minioStorage }}
  {{ printf "data%v" (int $idx) }}:
    enabled: true
    {{- include "minio.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      minio:
        minio:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
  # Minio writes temporary files to this directory. Adding this as an emptyDir,
  # So we don't have to set readOnlyRootFilesystem to false
  tempdir:
    enabled: true
    type: emptyDir
    targetSelector:
      minio:
        minio:
          mountPath: /.minio
  {{- if .Values.minioNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: minio-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: private.key
      - key: tls.crt
        path: public.crt
      - key: tls.crt
        path: CAs/public.crt
    targetSelector:
      minio:
        minio:
          mountPath: /.minio/certs
          readOnly: true
    {{- end -}}
{{- end -}}
