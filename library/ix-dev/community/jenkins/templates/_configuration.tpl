{{- define "jenkins.configuration" -}}
opts:
  jenkinsOpts:
    {{- if  not .Values.jenkinsNetwork.certificateID }}
    - --httpPort={{ .Values.jenkinsNetwork.webPort }}
    {{- end -}}
    {{- if .Values.jenkinsNetwork.certificateID }}
    - --httpPort=-1
    - --httpsPort={{ .Values.jenkinsNetwork.webPort }}
    - --httpsKeyStore={{ .Values.jenkinsConstants.keystorePath }}/{{ .Values.jenkinsConstants.keystoreName }}
    - --httpsKeyStorePassword={{ .Values.jenkinsCertRandomPass }}
    {{- end -}}
    {{- range $opt := .Values.jenkinsConfig.jenkinsOpts }}
    - --{{ $opt }}
    {{- end }}

  jenkinsJavaOpts:
    - -Djenkins.model.Jenkins.slaveAgentPortEnforce=true
    - -Djenkins.model.Jenkins.slaveAgentPort={{ ternary .Values.jenkinsNetwork.agentPort "-1" .Values.jenkinsNetwork.agent }}
    {{- range $opt := .Values.jenkinsConfig.jenkinsJavaOpts }}
    - -D{{ $opt.property }}={{ $opt.value }}
    {{- end }}
{{- end -}}
