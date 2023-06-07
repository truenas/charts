{{- define "jenkins.configuration" -}}
opts:
  javaOpts:
    {{- range $opt := .Values.jenkinsConfig.javaOpts }}
    - -{{ $opt }}
    {{- end }}

  jenkinsOpts:
    - --httpPort={{ ternary .Values.jenkinsNetwork.httpPort "-1" .Values.jenkinsNetwork.http }}
    {{- if .Values.jenkinsNetwork.https }}
    - --httpsPort={{ .Values.jenkinsNetwork.httpsPort }}
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
