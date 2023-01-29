{{- define "ix.v1.common.certificate.secret" -}}
  {{- $name := .name -}}
  {{- $cert := .cert -}}
  {{- $root := .root -}}
  {{- $tlsCrtKey := "tls.crt" -}}
  {{- $tlsPrivateKey := "tls.key" -}}

  {{- if not (hasKey $cert "id") -}} {{/* This is something that should not happen when using this library */}}
    {{- fail (printf "Certificate (%s) has no <id> key" $cert.nameOverride) -}}
  {{- end -}} {{/* It can only happen when consuing this function within this library */}}
  {{- $certID := (toString $cert.id) -}}

  {{- if (include "ix.v1.common.certificate.exists" (dict "root" $root "certID" $certID)) -}}
    {{/* Generate secret name here so we can pass it to persistenc */}}
    {{- $secretName := include "ix.v1.common.names.certificateSecret" (dict "root" $root "certValues" $cert "certName" $name "certID" $certID) -}}

    {{- include "ix.v1.common.certificate.persistence" (dict "root" $root "secretName" $secretName "cert" $cert "certID" $certID "tlsKey" $tlsCrtKey "type" "cert") -}}
    {{- include "ix.v1.common.certificate.persistence" (dict "root" $root "secretName" $secretName "cert" $cert "certID" $certID "tlsKey" $tlsPrivateKey "type" "key") -}}

    {{- $certData := dict -}}
    {{- $_ := set $certData $tlsCrtKey (include "ix.v1.common.certificate.get" (dict "root" $root "cert" $cert "key" "certificate")) -}}
    {{- $_ := set $certData $tlsPrivateKey (include "ix.v1.common.certificate.get" (dict "root" $root "cert" $cert "key" "privatekey")) -}}

    {{- $values := dict -}}
    {{- $_ := set $values "data" $certData -}}
    {{- $_ := set $values "name" $secretName -}}
    {{- $_ := set $values "contentType" "certificate" -}}

    {{/* Create the Secret */}}
    {{- include "ix.v1.common.class.secret" (dict "root" $root "values" $values) -}}
  {{- end -}}
{{- end -}}
