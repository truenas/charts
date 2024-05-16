{{- define "jenkins.workload" -}}
workload:
  jenkins:
    enabled: true
    primary: true
    type: Deployment
    podSpec:
      hostNetwork: {{ .Values.jenkinsNetwork.hostNetwork }}
      securityContext:
        fsGroup: 1000
      containers:
        jenkins:
          enabled: true
          primary: true
          imageSelector: image
          securityContext:
            runAsUser: 1000
            runAsGroup: 1000
          {{ $config := (include "jenkins.configuration" $ | fromYaml).opts }}
          env:
            JENKINS_SLAVE_AGENT_PORT: {{ .Values.jenkinsNetwork.agentPort }}
            JENKINS_JAVA_OPTS: {{ join " " $config.jenkinsJavaOpts }}
            JENKINS_OPTS: {{ join " " $config.jenkinsOpts }}
          {{ with .Values.jenkinsConfig.additionalEnvs }}
          envList:
            {{ range $env := . }}
            - name: {{ $env.name }}
              value: {{ $env.value }}
            {{ end }}
          {{ end }}
          {{ $scheme := "http" }}
          {{ if .Values.jenkinsNetwork.certificateID }}
            {{ $scheme = "https" }}
          {{ end }}
          probes:
            liveness:
              enabled: true
              type: {{ $scheme }}
              port: {{ .Values.jenkinsNetwork.webPort }}
              path: /login
            readiness:
              enabled: true
              type: {{ $scheme }}
              port: {{ .Values.jenkinsNetwork.webPort }}
              path: /login
            startup:
              enabled: true
              type: {{ $scheme }}
              port: {{ .Values.jenkinsNetwork.webPort }}
              path: /login
      initContainers:
      {{- include "ix.v1.common.app.permissions" (dict "containerName" "01-permissions"
                                                        "UID" 1000
                                                        "GID" 1000
                                                        "mode" "check"
                                                        "type" "install") | nindent 8 }}
      {{- if .Values.jenkinsNetwork.certificateID }}
        02-cert-container:
          {{- include "jenkins.certContainer" $ | nindent 10 }}
      {{- end }}

{{/* Service */}}
service:
  jenkins:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: jenkins
    ports:
      web:
        enabled: true
        primary: true
        port: {{ .Values.jenkinsNetwork.webPort }}
        nodePort: {{ .Values.jenkinsNetwork.webPort }}
        targetSelector: jenkins
  agent:
    enabled: {{ .Values.jenkinsNetwork.agent }}
    primary: false
    type: NodePort
    targetSelector: jenkins
    ports:
      agent:
        enabled: {{ .Values.jenkinsNetwork.agent }}
        primary: true
        port: {{ .Values.jenkinsNetwork.agentPort }}
        nodePort: {{ .Values.jenkinsNetwork.agentPort }}
        targetSelector: jenkins

{{/* Persistence */}}
persistence:
  home:
    enabled: true
    {{- include "jenkins.storage.ci.migration" (dict "storage" .Values.jenkinsStorage.home) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.jenkinsStorage.home) | nindent 4 }}
    targetSelector:
      jenkins:
        jenkins:
          mountPath: /var/jenkins_home
        {{- if and (eq .Values.jenkinsStorage.home.type "ixVolume")
                  (not (.Values.jenkinsStorage.home.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/jenkins_home
        {{- end }}
        02-cert-container:
          mountPath: /var/jenkins_home
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      jenkins:
        jenkins:
          mountPath: /tmp
        02-cert-container:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.jenkinsStorage.additionalStorages }}
  {{ printf "jenkins-%v:" (int $idx) }}
    enabled: true
    {{- include "jenkins.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      jenkins:
        jenkins:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
  {{- if .Values.jenkinsNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: jenkins-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: {{ .Values.jenkinsConstants.keyName }}
      - key: tls.crt
        path: {{ .Values.jenkinsConstants.crtName }}
    targetSelector:
      jenkins:
        02-cert-container:
          mountPath: {{ .Values.jenkinsConstants.certsPath }}
          readOnly: true

scaleCertificate:
  jenkins-cert:
    enabled: true
    id: {{ .Values.jenkinsNetwork.certificateID }}
    {{- end -}}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "jenkins.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
