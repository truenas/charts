{{- define "cloudflared.workload" -}}
{{- if not .Values.cloudflaredConfig.tunnelToken -}}
  {{- fail "Cloudflared - Tunnel Token is required" -}}
{{- end -}}
{{- $reservedArgs := (list "tunnel" "--no-autoupdate" "run") -}}
{{- $addArgs := .Values.cloudflaredConfig.additionalArgs -}}
{{- if not (deepEqual $addArgs (uniq $addArgs)) -}}
  {{- fail (printf "Cloudflared - Expected Additional arguments to be unique, but got [%s]" (join ", " $addArgs)) -}}
{{- end }}
workload:
  cloudflared:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.cloudflaredNetwork.hostNetwork }}
      containers:
        cloudflared:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.cloudflaredRunAs.user }}
            runAsGroup: {{ .Values.cloudflaredRunAs.group }}
          args:
            - tunnel
            - --no-autoupdate
            {{ if not .Values.ci }}
              {{ range $arg := $addArgs }}
                {{- if (mustHas $arg $reservedArgs) -}}
                  {{- fail (printf "Cloudflared - Argument [%s] is already applied" $arg) -}}
                {{- end }}
            - {{ $arg }}
              {{ end }}
            - run
            {{ else }}
            - --hello-world
            {{ end }}
          env:
            TUNNEL_TOKEN: {{ .Values.cloudflaredConfig.tunnelToken }}
          {{ with .Values.cloudflaredConfig.additionalEnvs }}
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
                                                        "UID" .Values.cloudflaredRunAs.user
                                                        "GID" .Values.cloudflaredRunAs.group
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
{{- end -}}
