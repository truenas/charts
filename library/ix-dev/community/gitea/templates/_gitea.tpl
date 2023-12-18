{{- define "gitea.workload" -}}
workload:
  gitea:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.giteaNetwork.hostNetwork }}
      containers:
        gitea:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.giteaRunAs.user }}
            runAsGroup: {{ .Values.giteaRunAs.group }}
          envFrom:
            - secretRef:
                name: gitea-creds
            - configMapRef:
                name: gitea-config
          {{ with .Values.giteaConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            {{ $protocol := "http" }}
            {{ if .Values.giteaNetwork.certificateID }}
              {{ $protocol = "https" }}
            {{ end }}
            liveness:
              enabled: true
              type: {{ $protocol }}
              path: /api/healthz
              port: {{ .Values.giteaNetwork.webPort }}
            readiness:
              enabled: true
              type: {{ $protocol }}
              path: /api/healthz
              port: {{ .Values.giteaNetwork.webPort }}
            startup:
              enabled: true
              type: {{ $protocol }}
              path: /api/healthz
              port: {{ .Values.giteaNetwork.webPort }}
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                    "UID" .Values.giteaRunAs.user
                                                    "GID" .Values.giteaRunAs.group
                                                    "mode" "check"
                                                    "type" "install") | nindent 8 }}
      {{- include "ix.v1.common.app.postgresWait" (dict "name" "postgres-wait"
                                                        "secretName" "postgres-creds") | nindent 8 }}
{{/* Service */}}
service:
  gitea:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: gitea
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.giteaNetwork.webPort }}
        nodePort: {{ .Values.giteaNetwork.webPort }}
        targetSelector: gitea
      ssh:
        enabled: true
        port: {{ .Values.giteaNetwork.sshPort }}
        nodePort: {{ .Values.giteaNetwork.sshPort }}
        targetSelector: gitea

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.giteaStorage.data) | nindent 4 }}
    targetSelector:
      gitea:
        gitea:
          mountPath: /var/lib/gitea
        {{- if and (eq .Values.giteaStorage.data.type "ixVolume")
                  (not (.Values.giteaStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.giteaStorage.config) | nindent 4 }}
    targetSelector:
      gitea:
        gitea:
          mountPath: /etc/gitea
        {{- if and (eq .Values.giteaStorage.config.type "ixVolume")
                  (not (.Values.giteaStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  gitea-temp:
    enabled: true
    type: emptyDir
    targetSelector:
      gitea:
        gitea:
          mountPath: /tmp/gitea

  {{- range $idx, $storage := .Values.giteaStorage.additionalStorages }}
  {{ printf "gitea-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      gitea:
        gitea:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{ if .Values.giteaNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: gitea-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: private.key
      - key: tls.crt
        path: public.crt
    targetSelector:
      gitea:
        gitea:
          mountPath: /etc/certs/gitea
          readOnly: true
  {{ end }}
{{- end -}}
