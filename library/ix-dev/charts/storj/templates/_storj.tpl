{{- define "storj.workload" -}}
workload:
  storj:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.storjNetwork.hostNetwork }}
      terminationGracePeriodSeconds: {{ .Values.storjConfig.gracePeriod }}
      containers:
        storj:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.storjRunAs.user }}
            runAsGroup: {{ .Values.storjRunAs.group }}
            readOnlyRootFilesystem: false
            # capabilities:
            #   add:
            #     - CHOWN
            #     - DAC_OVERRIDE
            #     - FOWNER
            #     - SETGID
            #     - SETUID
            #     - KILL
          {{- include "storj.args" $ | nindent 10 }}
          env:
            EMAIL: {{ .Values.storjConfig.email }}
            STORAGE: {{ printf "%vGB" .Values.storjConfig.storageSizeGB }}
            ADDRESS: {{ printf "%s:%v" .Values.storjConfig.domainAddress .Values.storjNetwork.p2pPort }}
            WALLET:
              secretKeyRef:
                name: storj
                key: wallet
          {{ with .Values.storjConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: false
            readiness:
              enabled: false
            startup:
              enabled: false
      initContainers:
        {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                                "UID" .Values.storjRunAs.user
                                                                "GID" .Values.storjRunAs.group
                                                                "mode" "check"
                                                                "type" "install") | nindent 8 }}
        02-generateid:
          enabled: true
          type: init
          imageSelector: curlImage
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - FOWNER
                - DAC_OVERRIDE
          command:
            - /bin/sh
            - -c
          args:
            - ./init_script/init_config.sh
          env:
            DEFAULT_CERT_PATH: {{ template "storj.idPath" }}/ca.cert
            DEFAULT_IDENTITY_CERT_PATH: {{ template "storj.idPath" }}/identity.cert
            AUTH_KEY:
              secretKeyRef:
                name: storj
                key: authToken
        03-setup:
          enabled: true
          type: init
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.storjRunAs.user }}
            runAsGroup: {{ .Values.storjRunAs.group }}
          command:
            - /bin/sh
            - -c
            - |
              test ! -f /app/config/config.yaml && export SETUP="true"; /entrypoint
{{- end -}}
