{{/* Templates for certificates injection */}}

{{- define "gitlab.certificates.initContainer" -}}
{{- $customCAsEnabled := .Values.global.certificates.customCAs }}
{{- $internalGitalyTLSEnabled := $.Values.global.gitaly.tls.enabled }}
{{- $internalPraefectTLSEnabled := and $.Values.global.praefect.tls.enabled $.Values.global.praefect.tls.secretName }}
{{- $certmanagerDisabled := not (or $.Values.global.ingress.configureCertmanager $.Values.global.ingress.tls) }}
{{- $imageCfg := dict "global" .Values.global.image "local" .Values.global.certificates.image -}}
- name: certificates
  image: "{{ .Values.global.certificates.image.repository }}:{{ .Values.global.certificates.image.tag }}"
  {{- include "gitlab.image.pullPolicy" $imageCfg | indent 2 }}
  env:
  {{- include "gitlab.extraEnv" . | nindent 2 }}
  volumeMounts:
  - name: etc-ssl-certs
    mountPath: /etc/ssl/certs
    readOnly: false
{{- if or $customCAsEnabled (or $certmanagerDisabled $internalGitalyTLSEnabled $internalPraefectTLSEnabled) }}
  - name: custom-ca-certificates
    mountPath: /usr/local/share/ca-certificates
    readOnly: true
{{- end }}
  resources:
    {{- toYaml .Values.init.resources | nindent 4 }}
{{- end -}}

{{- define "gitlab.certificates.volumes" -}}
{{- $customCAsEnabled := .Values.global.certificates.customCAs }}
{{- $internalGitalyTLSEnabled := $.Values.global.gitaly.tls.enabled }}
{{- $internalPraefectTLSEnabled := and $.Values.global.praefect.tls.enabled $.Values.global.praefect.tls.secretName }}
{{- $certmanagerDisabled := not (or $.Values.global.ingress.configureCertmanager $.Values.global.ingress.tls) }}
- name: etc-ssl-certs
  emptyDir:
    medium: "Memory"
{{- if or $customCAsEnabled (or $certmanagerDisabled $internalGitalyTLSEnabled $internalPraefectTLSEnabled) }}
- name: custom-ca-certificates
  projected:
    defaultMode: 0440
    sources:
    {{- range $index, $customCA := .Values.global.certificates.customCAs }}
    - secret:
        name: {{ $customCA.secret }}
        # items not specified, will mount all keys
    {{- end }}
    {{- if not (or $.Values.global.ingress.configureCertmanager $.Values.global.ingress.tls) }}
    - secret:
        name: {{ template "gitlab.wildcard-self-signed-cert-name" $ }}-ca
    {{- end }}
    {{- if $internalGitalyTLSEnabled }}
    {{-   if $.Values.global.praefect.enabled }}
    {{-     range $vs := $.Values.global.praefect.virtualStorages }}
    - secret:
        name: {{ $vs.tlsSecretName }}
        items:
        - key: "tls.crt"
          path: "gitaly-{{ $vs.name }}-tls.crt"
    {{-     end }}
    {{-   else }}
    - secret:
        name: {{ template "gitlab.gitaly.tls.secret" $ }}
        items:
          - key: "tls.crt"
            path: "gitaly-internal-tls.crt"
    {{-   end }}
    {{- end }}
    {{- if $internalPraefectTLSEnabled }}
    - secret:
        name: {{ template "gitlab.praefect.tls.secret" $ }}
        items:
          - key: "tls.crt"
            path: "praefect-internal-tls.crt"
    {{- end }}
{{- end -}}
{{- end -}}

{{- define "gitlab.certificates.volumeMount" -}}
- name: etc-ssl-certs
  mountPath: /etc/ssl/certs/
  readOnly: true
{{- end -}}
