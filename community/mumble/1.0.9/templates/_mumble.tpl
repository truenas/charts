{{- define "mumble.workload" -}}
workload:
  mumble:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        mumble:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
          envFrom:
            - configMapRef:
                name: mumble-config
            - secretRef:
                name: mumble-secret
          {{ with .Values.mumbleConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            # Probes are disabled because it fills the logs with
            # "connection attemps"
            liveness:
              enabled: {{ .Values.ci }}
              type: tcp
              port: "{{ .Values.mumbleNetwork.serverPort }}"
            readiness:
              enabled: {{ .Values.ci }}
              type: tcp
              port: "{{ .Values.mumbleNetwork.serverPort }}"
            startup:
              enabled: {{ .Values.ci }}
              type: tcp
              port: "{{ .Values.mumbleNetwork.serverPort }}"
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 1000
                                                        "GID" 1000
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}

{{/* Service */}}
service:
  mumble:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: mumble
    ports:
      tcp:
        enabled: true
        primary: true
        port: {{ .Values.mumbleNetwork.serverPort }}
        nodePort: {{ .Values.mumbleNetwork.serverPort }}
        targetSelector: mumble
      udp:
        enabled: true
        port: {{ .Values.mumbleNetwork.serverPort }}
        nodePort: {{ .Values.mumbleNetwork.serverPort }}
        protocol: udp
        targetSelector: mumble
  ice:
    enabled: true
    type: NodePort
    targetSelector: mumble
    ports:
      ice:
        enabled: true
        primary: true
        port: {{ .Values.mumbleNetwork.icePort }}
        nodePort: {{ .Values.mumbleNetwork.icePort }}
        targetSelector: mumble

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    type: {{ .Values.mumbleStorage.data.type }}
    datasetName: {{ .Values.mumbleStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.mumbleStorage.data.hostPath | default "" }}
    targetSelector:
      mumble:
        mumble:
          mountPath: /data
        01-permissions:
          mountPath: /mnt/directories/data

  {{- if .Values.mumbleNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: mumble-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: private.key
      - key: tls.crt
        path: public.crt
    targetSelector:
      mumble:
        mumble:
          mountPath: /certs
          readOnly: true

scaleCertificate:
  mumble-cert:
    enabled: true
    id: {{ .Values.mumbleNetwork.certificateID }}
    {{- end -}}
{{- end -}}
