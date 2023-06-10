{{- define "jenkins.validation" -}}

  {{- if not (deepEqual (uniq .Values.jenkinsConfig.jenkinsJavaOpts) .Values.jenkinsConfig.jenkinsJavaOpts) -}}
    {{- fail "Jenkins - Jenkins Java Options must be unique" -}}
  {{- end -}}

  {{- if not (deepEqual (uniq .Values.jenkinsConfig.jenkinsOpts) .Values.jenkinsConfig.jenkinsOpts) -}}
    {{- fail "Jenkins - Jenkins Options must be unique" -}}
  {{- end -}}

  {{- $reservedJenkinsJavaOpts := (list
                                    "jenkins.model.Jenkins.slaveAgentPortEnforce"
                                    "jenkins.model.Jenkins.slaveAgentPort") -}}
  {{- $reservedJenkinsOpts := (list "httpPort") -}}

  {{- if .Values.jenkinsNetwork.certificateID -}}
    {{- $reservedJenkinsOpts = mustAppend $reservedJenkinsOpts "httpsPort" -}}
    {{- $reservedJenkinsOpts = mustAppend $reservedJenkinsOpts "httpsKeyStore" -}}
  {{- end -}}

  {{- range $opt := .Values.jenkinsConfig.jenkinsOpts -}}
    {{- if (hasPrefix "--" $opt) -}}
      {{- fail "Jenkins - Please remove [--] prefix from Jenkins Option [%v], as it is added automatically." -}}
    {{- end -}}
    {{- if (mustHas $opt $reservedJenkinsOpts) -}}
      {{- fail "Jenkins - Setting Jenkins Option [%v] is not allowed." -}}
    {{- end -}}
  {{- end -}}

  {{- range $opt := .Values.jenkinsConfig.jenkinsJavaOpts -}}
    {{- if (hasPrefix "-D" $opt.property) -}}
      {{- fail "Jenkins - Please remove [-D] prefix from Jenkins Java Option [%v], as it is added automatically." -}}
    {{- end -}}
    {{- if (mustHas $opt.property $reservedJenkinsJavaOpts) -}}
      {{- fail "Jenkins - Setting Jenkins Java Option [%v] is not allowed." -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
