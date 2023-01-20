{{/*
Ensure that tenantId and clientId are set if Microsoft Graph settings are used in incomingEmail
*/}}
{{- define "gitlab.checkConfig.incomingEmail.microsoftGraph" -}}
{{- with $.Values.global.appConfig.incomingEmail }}
{{-   if (and .enabled (eq .inboxMethod "microsoft_graph")) }}
{{-     if not .tenantId }}
incomingEmail:
    When configuring incoming email with Microsoft Graph, be sure to specify the tenant ID.
    See https://docs.gitlab.com/ee/administration/incoming_email.html#microsoft-graph
{{-     end -}}
{{-     if not .clientId }}
incomingEmail:
    When configuring incoming email with Microsoft Graph, be sure to specify the client ID.
    See https://docs.gitlab.com/ee/administration/incoming_email.html#microsoft-graph
{{-     end -}}
{{-   end -}}
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.incomingEmail.microsoftGraph */}}

{{/*
Ensure that incomingEmail is enabled too if serviceDesk is enabled
*/}}
{{- define "gitlab.checkConfig.serviceDesk" -}}
{{-   if $.Values.global.appConfig.serviceDeskEmail.enabled }}
{{-     if not $.Values.global.appConfig.incomingEmail.enabled }}
serviceDesk:
    When configuring Service Desk email, you must also configure incoming email.
    See https://docs.gitlab.com/charts/charts/globals#incoming-email-settings
{{-     end -}}
{{-     if (not (and (contains "+%{key}@" $.Values.global.appConfig.incomingEmail.address) (contains "+%{key}@" $.Values.global.appConfig.serviceDeskEmail.address))) }}
serviceDesk:
    When configuring Service Desk email, both incoming email and Service Desk email address must contain the "+%{key}" tag.
    See https://docs.gitlab.com/ee/user/project/service_desk.html#using-custom-email-address
{{-     end -}}
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.serviceDesk */}}

{{/*
Ensure that tenantId and clientId are set if Microsoft Graph settings are used in serviceDesk
*/}}
{{- define "gitlab.checkConfig.serviceDesk.microsoftGraph" -}}
{{- with $.Values.global.appConfig.serviceDesk }}
{{-   if (and .enabled (eq .inboxMethod "microsoft_graph")) }}
{{-     if not .tenantId }}
incomingEmail:
    When configuring Service Desk with Microsoft Graph, be sure to specify the tenant ID.
    See https://docs.gitlab.com/ee/user/project/service_desk.html#microsoft-graph
{{-     end -}}
{{-     if not .clientId }}
incomingEmail:
    When configuring Service Desk with Microsoft Graph, be sure to specify the client ID.
    See https://docs.gitlab.com/ee/user/project/service_desk.html#microsoft-graph
{{-     end -}}
{{-   end -}}
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.serviceDesk.microsoftGraph */}}

{{/*
Ensure that incomingEmail's deliveryMethod is either sidekiq or webhook
*/}}
{{- define "gitlab.checkConfig.incomingEmail.deliveryMethod" -}}
{{- if not (or (eq $.Values.global.appConfig.incomingEmail.deliveryMethod "sidekiq") (eq $.Values.global.appConfig.incomingEmail.deliveryMethod "webhook")) }}
incomingEmail:
    Delivery method should be either "sidekiq" or "webhook"
    See https://docs.gitlab.com/charts/installation/command-line-options.html#incoming-email-configuration
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.incomingEmail.deliveryMethod */}}

{{/*
Ensure that serviceDeskEmail's deliveryMethod is either sidekiq or webhook
*/}}
{{- define "gitlab.checkConfig.serviceDeskEmail.deliveryMethod" -}}
{{- if not (or (eq $.Values.global.appConfig.serviceDeskEmail.deliveryMethod "sidekiq") (eq $.Values.global.appConfig.serviceDeskEmail.deliveryMethod "webhook")) }}
serviceDeskEmail:
    Delivery method should be either "sidekiq" or "webhook"
    See https://docs.gitlab.com/charts/installation/command-line-options.html#service-desk-email-configuration
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.serviceDeskEmail.deliveryMethod */}}
