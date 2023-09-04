{{- define "upb.workload" -}}
workload:
  unifi-protect:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      securityContext:
        fsGroup: {{ .Values.upbID.group }}
      containers:
        unifi-protect:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - FOWNER
                - SETUID
                - SETGID
          fixedEnv:
            PUID: {{ .Values.upbID.user }}
          envFrom:
            - configMapRef:
                name: upb-config
            - secretRef:
                name: upb-creds
          {{ with .Values.upbConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            # Nothing to probe
            liveness:
              enabled: false
            readiness:
              enabled: false
            startup:
              enabled: false
{{- end -}}
