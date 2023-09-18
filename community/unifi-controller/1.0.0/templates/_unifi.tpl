{{- define "unifi.workload" -}}
workload:
  unifi:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.unifiNetwork.hostNetwork }}
      containers:
        unifi:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 999
            runAsGroup: 999
            readOnlyRootFilesystem: false
          env:
            UNIFI_STDOUT: true
            UNIFI_HTTP_PORT: {{ .Values.unifiNetwork.webHttpPort }}
            UNIFI_HTTPS_PORT: {{ .Values.unifiNetwork.webHttpsPort }}
            PORTAL_HTTP_PORT: {{ .Values.unifiNetwork.portalHttpPort }}
            PORTAL_HTTPS_PORT: {{ .Values.unifiNetwork.portalHttpsPort }}
            {{- if .Values.unifiNetwork.certificateID }}
            CERTNAME: cert.pem
            CERT_PRIVATE_NAME: privkey.pem
            CERT_IS_CHAIN: true
            {{- end }}
          {{ with .Values.unifiConfig.additionalEnvs }}
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
              command: /usr/local/bin/docker-healthcheck.sh
            readiness:
              enabled: true
              type: exec
              command: /usr/local/bin/docker-healthcheck.sh
            startup:
              enabled: true
              type: exec
              command: /usr/local/bin/docker-healthcheck.sh
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 999
                                                        "GID" 999
                                                        "mode" "check"
                                                        "type" "init") | nindent 8 }}
      {{- if .Values.unifiNetwork.certificateID }}
        # Unifi chowns the files on startup, and if we mount them directly
        # from the secret, it will fail to start. So we make copy.
        02-certs:
          enabled: true
          type: init
          imageSelector: image
          securityContext:
            runAsUser: 999
            runAsGroup: 999
            readOnlyRootFilesystem: false
          command:
            - /bin/sh
            - -c
          args:
            - |
              certdir=/unifi/cert
              echo "Copying certificates to $certdir"
              mkdir -p $certdir
              cp --force --verbose /ix/cert/private.key $certdir/privkey.pem
              cp --force --verbose /ix/cert/public.crt $certdir/cert.pem
              cp --force --verbose /ix/cert/public.crt $certdir/chain.pem
      {{- end -}}
{{- end -}}
