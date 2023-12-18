{{- define "vaultwarden.workload" -}}
workload:
  vaultwarden:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.vaultwardenNetwork.hostNetwork }}
      containers:
        vaultwarden:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.vaultwardenRunAs.user }}
            runAsGroup: {{ .Values.vaultwardenRunAs.group }}
          env:
            ROCKET_PORT: {{ .Values.vaultwardenNetwork.webPort }}
            WEBSOCKET_PORT: {{ .Values.vaultwardenNetwork.wsPort }}
            WEBSOCKET_ENABLED: {{ .Values.vaultwardenNetwork.wsEnabled }}
            DATABASE_URL:
              secretKeyRef:
                name: postgres-creds
                key: POSTGRES_URL
            {{ if .Values.vaultwardenConfig.adminToken }}
            ADMIN_TOKEN:
              secretKeyRef:
                name: vaultwarden
                key: ADMIN_TOKEN
            {{ end }}
            {{ if .Values.vaultwardenNetwork.certificateID }}
            ROCKET_TLS: '{certs="/certs/public.crt",key="/certs/private.key"}'
            {{ end }}
            {{ with .Values.vaultwardenNetwork.domain }}
            DOMAIN: {{ . }}
            {{ end }}
          {{ with .Values.vaultwardenConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: exec
              command: /healthcheck.sh
            readiness:
              enabled: true
              type: exec
              command: /healthcheck.sh
            startup:
              enabled: true
              type: exec
              command: /healthcheck.sh
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                    "UID" .Values.vaultwardenRunAs.user
                                                    "GID" .Values.vaultwardenRunAs.group
                                                    "mode" "check"
                                                    "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}

{{/* Service */}}
service:
  vaultwarden:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: vaultwarden
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.vaultwardenNetwork.webPort }}
        nodePort: {{ .Values.vaultwardenNetwork.webPort }}
        targetSelector: vaultwarden
      ws:
        enabled: {{ .Values.vaultwardenNetwork.wsEnabled }}
        port: {{ .Values.vaultwardenNetwork.wsPort }}
        nodePort: {{ .Values.vaultwardenNetwork.wsPort }}
        targetSelector: vaultwarden

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.vaultwardenStorage.data) | nindent 4 }}
    targetSelector:
      vaultwarden:
        vaultwarden:
          mountPath: /data
        {{- if and (eq .Values.vaultwardenStorage.data.type "ixVolume")
                  (not (.Values.vaultwardenStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}

  {{- range $idx, $storage := .Values.vaultwardenStorage.additionalStorages }}
  {{ printf "vaultwarden-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      vaultwarden:
        vaultwarden:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{- if .Values.vaultwardenNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: vaultwarden-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: private.key
      - key: tls.crt
        path: public.crt
    targetSelector:
      vaultwarden:
        vaultwarden:
          mountPath: /certs
          readOnly: true

scaleCertificate:
  vaultwarden-cert:
    enabled: true
    id: {{ .Values.vaultwardenNetwork.certificateID }}
    {{- end -}}
{{- end -}}
