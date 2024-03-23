{{- define "audiobookshelf.workload" -}}
workload:
  audiobookshelf:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.audiobookshelfNetwork.hostNetwork }}
      containers:
        audiobookshelf:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: {{ .Values.audiobookshelfRunAs.user }}
            runAsGroup: {{ .Values.audiobookshelfRunAs.group }}
          {{ with .Values.audiobookshelfConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: http
              port: "{{ .Values.audiobookshelfNetwork.webPort }}"
              path: /
            readiness:
              enabled: true
              type: http
              port: "{{ .Values.audiobookshelfNetwork.webPort }}"
              path: /
            startup:
              enabled: true
              type: http
              port: "{{ .Values.audiobookshelfNetwork.webPort }}"
              path: /
{{- end -}}
