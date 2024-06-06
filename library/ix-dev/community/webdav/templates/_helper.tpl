{{/* Webdav HTTP Config */}}
{{- define "webdav.http.config" -}}
Listen {{ .Values.webdavNetwork.httpPort }}
<VirtualHost *:{{ .Values.webdavNetwork.httpPort }}>
  {{- include "webdav.health.config" $ | nindent 2 }}
  {{- include "webdav.core.config" $ | nindent 2 }}
</VirtualHost>
{{- end -}}

{{/* Webdav HTTPS Config */}}
{{- define "webdav.https.config" -}}
Listen {{ .Values.webdavNetwork.httpsPort }}
<VirtualHost *:{{ .Values.webdavNetwork.httpsPort }}>
  {{- if not .Values.webdavNetwork.http }}
    {{- include "webdav.health.config" $ | nindent 2 }}
  {{- end }}
  SSLEngine on
  SSLCertificateFile "{{ include "webdav.path.cert.crt" $ }}"
  SSLCertificateKeyFile "{{ include "webdav.path.cert.key" $ }}"
  SSLProtocol +TLSv1.2 +TLSv1.3
  SSLCipherSuite HIGH:MEDIUM
  {{- include "webdav.core.config" $ | nindent 2 }}
</VirtualHost>
{{- end -}}

{{/* WebDav Core Config */}}
{{- define "webdav.core.config" -}}
DavLockDB "/usr/local/apache2/var/DavLock"
<Directory />
{{- if ne .Values.webdavConfig.authType "none" }}
  {{- include "webdav.auth.config" $ | nindent 2 }}
{{- end }}
  Dav On
  IndexOptions Charset=utf-8
  AddDefaultCharset UTF-8
  AllowOverride None
  Order allow,deny
  Allow from all
  Options Indexes FollowSymLinks
</Directory>
{{- range .Values.webdavStorage.shares }}
  {{ $bytesGB := 1073741824 }}
  {{- if .enabled }}
# WebDav Share - {{ .name }}
# Description: {{ .description }}
Alias /{{ .name }} "/{{ include "webdav.shares.prefix" $ }}/{{ .name }}"
<Directory "/{{ include "webdav.shares.prefix" $ }}/{{ .name }}">
  {{- $maxReqBody := 1 -}}
  {{- if not (kindIs "invalid" .maxRequestBodySizeInGB) -}}
    {{- $maxReqBody = mul .maxRequestBodySizeInGB $bytesGB -}}
  {{- end }}
  LimitRequestBody {{ $maxReqBody }}
</Directory>
    {{- if .readOnly }}
<Location "/{{ .name }}">
  AllowMethods GET OPTIONS PROPFIND
</Location>
    {{- end }}
  {{- end }}
{{- end }}
# The following directives disable redirects on non-GET requests for
# a directory that does not include the trailing slash.  This fixes a
# problem with several clients that do not appropriately handle
# redirects for folders with DAV methods.
BrowserMatch "Microsoft Data Access Internet Publishing Provider" redirect-carefully
BrowserMatch "MS FrontPage" redirect-carefully
BrowserMatch "^WebDrive" redirect-carefully
BrowserMatch "^WebDAVFS/1.[01234]" redirect-carefully
BrowserMatch "^gnome-vfs/1.0" redirect-carefully
BrowserMatch "^XML Spy" redirect-carefully
BrowserMatch "^Dreamweaver-WebDAV-SCM1" redirect-carefully
BrowserMatch "^DAVx5" redirect-carefully
BrowserMatch " Konqueror/4" redirect-carefully
{{- range $match := .Values.webdavConfig.additionalBrowserMatches }}
BrowserMatch "{{ $match }}" redirect-carefully
{{- end }}
RequestReadTimeout handshake=0 header=20-40,MinRate=500 body=20,MinRate=500
{{- end -}}

{{/* Included when authType is not "none" */}}
{{- define "webdav.auth.config" -}}
AuthType {{ .Values.webdavConfig.authType }}
AuthName webdav
AuthUserFile "/etc/apache2/webdavht{{ .Values.webdavConfig.authType }}"
Require valid-user
{{- end -}}

{{/* Included in one of the configs (webdav or webdav-ssl)
    Used as a healthcheck endpoint */}}
{{- define "webdav.health.config" -}}
<Location "/health">
  RewriteEngine On
  RewriteRule .* - [R=200]
</Location>
{{- end -}}

{{/* Creates the basic auth password */}}
{{- define "webdav.htauth" -}}
  {{- if eq .Values.webdavConfig.authType "basic" -}}
    {{- htpasswd .Values.webdavConfig.username .Values.webdavConfig.password -}}
  {{- end -}}
{{- end -}}

{{/* Prints the crt path
  Used in mountPath of the secret and on the webdav-ssl.conf */}}
{{- define "webdav.path.cert.crt" -}}
  {{- print "/etc/certificates/tls.crt" -}}
{{- end -}}

{{/* Prints the key path
  Used in mountPath of the secret and on the webdav-ssl.conf */}}
{{- define "webdav.path.cert.key" -}}
  {{- print "/etc/certificates/tls.key" -}}
{{- end -}}

{{/* Prints the shares base path inside the container
  Used in mountPath of the volume and on the webdav*.conf */}}
{{- define "webdav.shares.prefix" -}}
  {{- print "shares" -}}
{{- end -}}
