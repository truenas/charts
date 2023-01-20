{{/* ######### Registry related templates */}}

{{/*
Return the registry certificate secret name
*/}}
{{- define "gitlab.registry.certificate.secret" -}}
{{- default (printf "%s-registry-secret" .Release.Name) .Values.global.registry.certificate.secret | quote -}}
{{- end -}}

{{/*
Return the registry's httpSecert secret name
*/}}
{{- define "gitlab.registry.httpSecret.secret" -}}
{{- default (printf "%s-registry-httpsecret" .Release.Name) .Values.global.registry.httpSecret.secret | quote -}}
{{- end -}}

{{/*
Return the registry's httpSecert secret key
*/}}
{{- define "gitlab.registry.httpSecret.key" -}}
{{- default "secret" .Values.global.registry.httpSecret.key | quote -}}
{{- end -}}

{{/*
Return the registry's notification secret name
*/}}
{{- define "gitlab.registry.notificationSecret.secret" -}}
{{- default (printf "%s-registry-notification" .Release.Name) .Values.global.registry.notificationSecret.secret | quote -}}
{{- end -}}

{{/*
Return the registry's notification secret key
*/}}
{{- define "gitlab.registry.notificationSecret.key" -}}
{{- default "secret" .Values.global.registry.notificationSecret.key | quote -}}
{{- end -}}

{{/*
Return the registry's notification mount
*/}}
{{- define "gitlab.registry.notificationSecret.mount" -}}
- secret:
    name: {{ template "gitlab.registry.notificationSecret.secret" $ }}
    items:
      - key: {{ template "gitlab.registry.notificationSecret.key" $ }}
        path: registry/notificationSecret
{{- end -}}

{{/*
When Geo + Container Registry syncing enabled, adds the following notifier
*/}}
{{- define "global.geo.registry.syncNotifier" -}}
{{- if and .Values.global.geo.enabled .Values.global.geo.registry.replication.enabled -}}
endpoints:
  - name: geo_event
    url: https://{{ include "gitlab.gitlab.hostname" . }}/api/v4/container_registry_event/events
    timeout: 2s
    threshold: 5
    backoff: 1s
    headers:
      Authorization:
        secret: {{ template "gitlab.registry.notificationSecret.secret" $ }}
        key: {{ template "gitlab.registry.notificationSecret.key" $ }}
{{- else -}}
endpoints: []
{{- end -}}
{{- end -}}
