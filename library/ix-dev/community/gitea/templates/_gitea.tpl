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
          env:
            {{ range $env := . }}
            {{ $env.name }}: {{ $env.value }}
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
                                                        "type" "install") | nindent 8 }}
        db-wait:
          enabled: true
          type: init
          imageSelector: postgresImage
          envFrom:
            - secretRef:
                name: postgres-creds
          resources:
            limits:
              cpu: 500m
              memory: 256Mi
          command: bash
          args:
            - -c
            - |
              echo "Waiting for postgres to be ready"
              until pg_isready -h ${POSTGRES_HOST} -U ${POSTGRES_USER} -d ${POSTGRES_DB}; do
                sleep 2
              done

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
    type: {{ .Values.giteaStorage.data.type }}
    datasetName: {{ .Values.giteaStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.giteaStorage.data.hostPath | default "" }}
    targetSelector:
      gitea:
        gitea:
          mountPath: /var/lib/gitea
        01-permissions:
          mountPath: /mnt/directories/data
  config:
    enabled: true
    type: {{ .Values.giteaStorage.config.type }}
    datasetName: {{ .Values.giteaStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.giteaStorage.config.hostPath | default "" }}
    targetSelector:
      gitea:
        gitea:
          mountPath: /etc/gitea
        01-permissions:
          mountPath: /mnt/directories/config
  gitea-temp:
    enabled: true
    type: emptyDir
    targetSelector:
      gitea:
        gitea:
          mountPath: /tmp/gitea
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
