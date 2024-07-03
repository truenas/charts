{{- define "webdav.workload" -}}
workload:
  webdav:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.webdavNetwork.hostNetwork }}
      securityContext:
        fsGroup: {{ .Values.webdavRunAs.group }}
      containers:
        webdav:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.webdavRunAs.user }}
            runAsGroup: {{ .Values.webdavRunAs.group }}
          envList:
          {{ with .Values.webdavConfig.additionalEnvs }}
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          {{ $port := .Values.webdavNetwork.httpPort }}
          {{ $scheme := "http" }}
          {{ if not .Values.webdavNetwork.http }}
            {{ $port = .Values.webdavNetwork.httpsPort }}
            {{ $scheme = "https" }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: {{ $scheme }}
              path: /health
              port: {{ $port }}
            {{ if eq .Values.webdavConfig.authType "basic" }}
              httpHeaders:
                Authorization: Basic {{ (printf "%s:%s" .Values.webdavConfig.username .Values.webdavConfig.password) | b64enc }}
            {{ end }}
            readiness:
              enabled: true
              type: {{ $scheme }}
              path: /health
              port: {{ $port }}
            {{ if eq .Values.webdavConfig.authType "basic" }}
              httpHeaders:
                Authorization: Basic {{ (printf "%s:%s" .Values.webdavConfig.username .Values.webdavConfig.password) | b64enc }}
            {{ end }}
            startup:
              enabled: true
              type: {{ $scheme }}
              path: /health
              port: {{ $port }}
            {{ if eq .Values.webdavConfig.authType "basic" }}
              httpHeaders:
                Authorization: Basic {{ (printf "%s:%s" .Values.webdavConfig.username .Values.webdavConfig.password) | b64enc }}
            {{ end }}
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" .Values.webdavRunAs.user
                                                        "GID" .Values.webdavRunAs.group
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}

{{/* Service */}}
service:
  webdav:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: webdav
    ports:
      http:
        enabled: {{ .Values.webdavNetwork.http }}
        primary: true
        port: {{ .Values.webdavNetwork.httpPort }}
        nodePort: {{ .Values.webdavNetwork.httpPort }}
        targetSelector: webdav
      https:
        enabled: {{ .Values.webdavNetwork.https }}
        primary: {{ not .Values.webdavNetwork.http }}
        port: {{ .Values.webdavNetwork.httpsPort }}
        nodePort: {{ .Values.webdavNetwork.httpsPort }}
        targetSelector: webdav

{{/* Persistence */}}
persistence:
  httpd-conf:
    enabled: true
    type: configmap
    objectName: config
    targetSelector:
      webdav:
        webdav:
          mountPath: /usr/local/apache2/conf/httpd.conf
          subPath: httpd.conf
          readOnly: true
  webdav-conf:
    # Mount config only if http is enabled
    enabled: {{ .Values.webdavNetwork.http }}
    type: configmap
    objectName: config
    targetSelector:
      webdav:
        webdav:
          mountPath: /usr/local/apache2/conf/Includes/webdav.conf
          readOnly: true
          subPath: webdav.conf
  webdav-ssl-conf:
    # Mount config only if https is enabled
    enabled: {{ .Values.webdavNetwork.https }}
    type: configmap
    objectName: config
    targetSelector:
      webdav:
        webdav:
          mountPath: /usr/local/apache2/conf/Includes/webdav-ssl.conf
          subPath: webdav-ssl.conf
          readOnly: true
  htauth:
    # Mount config only if auth is enabled
    enabled: {{ ne .Values.webdavConfig.authType "none" }}
    type: secret
    objectName: htauth
    targetSelector:
      webdav:
        webdav:
          mountPath: /etc/apache2/webdavht{{ .Values.webdavConfig.authType }}
          subPath: htauth
          readOnly: true
  apachelock:
    # Stores PID file and DavLockDB file
    enabled: true
    type: emptyDir
    medium: Memory
    #TODO: Is this enough?
    size: 100Mi
    targetSelector:
      webdav:
        webdav:
          mountPath: /usr/local/apache2/var
  {{ range $idx, $storage := .Values.webdavStorage.shares }}
  {{ printf "webdav-%v" (int $idx) }}:
    enabled: {{ $storage.enabled }}
    type: hostPath
    hostPath: {{ $storage.hostPath }}
    targetSelector:
      webdav:
        webdav:
          # This path is used in the Alias directive in the webdav.conf
          mountPath: /{{ include "webdav.shares.prefix" $ }}/{{ $storage.name }}
          readOnly: {{ $storage.readOnly }}
        {{ if $storage.fixPermissions }}
        01-permissions:
          mountPath: /mnt/directories/{{ $storage.name }}
          readOnly: false
        {{ end }}
  {{ end }}
{{ if .Values.webdavNetwork.certificateID }}
  {{/* Mount Certificate */}}
  tls-crt:
    enabled: true
    type: secret
    objectName: webdav-cert
    defaultMode: "0600"
    targetSelector:
      webdav:
        webdav:
          mountPath: {{ include "webdav.path.cert.crt" $ }}
          subPath: tls.crt
          readOnly: true
  tls-key:
    enabled: true
    type: secret
    objectName: webdav-cert
    defaultMode: "0600"
    targetSelector:
      webdav:
        webdav:
          mountPath: {{ include "webdav.path.cert.key" $ }}
          subPath: tls.key
          readOnly: true
{{/* Certificate Secret */}}
scaleCertificate:
  webdav-cert:
    enabled: true
    id: {{ .Values.webdavNetwork.certificateID }}
{{ end }}
{{- end -}}
