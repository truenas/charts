{{- define "jenkins.certContainer" -}}
enabled: true
type: init
imageSelector: image
securityContext:
  runAsUser: 1000
  runAsGroup: 1000
command:
  - /bin/sh
  - -c
args:
  - |
    {{- $key := printf "%v/%v" .Values.jenkinsConstants.certsPath .Values.jenkinsConstants.keyName -}}
    {{- $cert := printf "%v/%v" .Values.jenkinsConstants.certsPath .Values.jenkinsConstants.crtName -}}
    {{- $keystore := printf "%v/%v" .Values.jenkinsConstants.keystorePath .Values.jenkinsConstants.keystoreName }}
    # Create the directories for the certificates and keystore
    mkdir -p "{{ .Values.jenkinsConstants.certsPath }}"
    mkdir -p "{{ .Values.jenkinsConstants.keystorePath }}"

    if [ -f "/tmp/ix.p12" ]; then
      echo "Cleaning up old certificate"
      rm "/tmp/ix.p12"
    fi

    echo "Generating new certificate from key and cert"

    if [ -f "{{ $key }}" ] && [ -f "{{ $cert }}" ]; then
      echo "Found key and cert, creating p12 certificate"

      openssl pkcs12 -inkey "{{ $key }}" -in "{{ $cert }}" \
                      -export -out "/tmp/ix.p12" \
                      -password pass:{{ .Values.jenkinsCertRandomPass }} || exit 1
      echo "P12 Certificate created"

      if [ -f "{{ $keystore }}" ]; then
        echo "Keystore already exists, removing and creating a new one"
        rm "{{ $keystore }}"
      fi

      echo "Importing certificate into a new java keystore"
      keytool -importkeystore -srckeystore "/tmp/ix.p12" -srcstoretype pkcs12 \
              -destkeystore "{{ $keystore }}" -deststoretype JKS \
              -srcstorepass {{ .Values.jenkinsCertRandomPass }} \
              -deststorepass {{ .Values.jenkinsCertRandomPass }} || exit 1

      echo "Certificate imported"
    fi
{{- end -}}
