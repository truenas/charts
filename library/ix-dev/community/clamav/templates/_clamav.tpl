{{- define "clamav.workload" -}}
workload:
  clamav:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: false
      containers:
        clamav:
          enabled: true
          primary: true
          tty: true
          stdin: true
          imageSelector: image
          securityContext:
            # FIXME: https://github.com/Cisco-Talos/clamav/issues/478
            runAsUser: 0
            runAsGroup: 0
            runAsNonRoot: false
            readOnlyRootFilesystem: false
            capabilities:
              add:
                - CHOWN
                - DAC_OVERRIDE
                - FOWNER
                - SETUID
                - SETGID
          env:
            CLAMAV_NO_CLAMD: {{ .Values.clamavConfig.disableClamd | quote }}
            CLAMAV_NO_FRESHCLAMD: {{ .Values.clamavConfig.disableFreshClamd | quote }}
            CLAMAV_NO_MILTERD: {{ .Values.clamavConfig.disableMilterd | quote }}
            CLAMD_STARTUP_TIMEOUT: {{ .Values.clamavConfig.clamdStartupTimeout | quote }}
            FRESHCLAM_CHECKS: {{ .Values.clamavConfig.freshclamChecks | quote }}
          {{ with .Values.clamavConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          probes:
            liveness:
              enabled: {{ not .Values.clamavConfig.disableClamd }}
              type: exec
              command: clamdcheck.sh
            readiness:
              enabled: {{ not .Values.clamavConfig.disableClamd }}
              type: exec
              command: clamdcheck.sh
            startup:
              enabled: {{ not .Values.clamavConfig.disableClamd }}
              type: exec
              command: clamdcheck.sh

{{/* Service */}}
service:
  clamav:
    enabled: {{ or (not .Values.clamavConfig.disableClamd) (not .Values.clamavConfig.disableMilterd) }}
    primary: true
    type: NodePort
    targetSelector: clamav
    ports:
      clamd:
        enabled: {{ not .Values.clamavConfig.disableClamd }}
        primary: true
        port: {{ .Values.clamavNetwork.clamdPort }}
        nodePort: {{ .Values.clamavNetwork.clamdPort }}
        targetPort: 3310
        targetSelector: clamav
      milted:
        enabled: {{ not .Values.clamavConfig.disableMilterd }}
        primary: {{ .Values.clamavConfig.disableClamd }}
        port: {{ .Values.clamavNetwork.milterdPort }}
        nodePort: {{ .Values.clamavNetwork.milterdPort }}
        targetPort: 7357
        targetSelector: clamav

{{/* Persistence */}}
persistence:
  data:
    enabled: true
    type: {{ .Values.clamavStorage.sigdb.type }}
    datasetName: {{ .Values.clamavStorage.sigdb.datasetName | default "" }}
    hostPath: {{ .Values.clamavStorage.sigdb.hostPath | default "" }}
    targetSelector:
      clamav:
        clamav:
          mountPath: /var/lib/clamav
  scan-dir:
    enabled: true
    type: {{ .Values.clamavStorage.scandir.type }}
    datasetName: {{ .Values.clamavStorage.scandir.datasetName | default "" }}
    hostPath: {{ .Values.clamavStorage.scandir.hostPath | default "" }}
    targetSelector:
      clamav:
        clamav:
          mountPath: /scandir
{{- end -}}
