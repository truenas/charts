{{- define "ix.v1.common.loader.apply" -}}

  {{- include "ix.v1.common.spawner.externalInterface" . | nindent 0 -}}

  {{- include "ix.v1.common.spawner.certificate" . | nindent 0 -}}

  {{- include "ix.v1.common.spawner.imagePullSecret" . | nindent 0 -}}

  {{- include "ix.v1.common.spawner.serviceAccount" . | nindent 0 -}}

  {{- include "ix.v1.common.spawner.rbac" . | nindent 0 -}}

  {{- include "ix.v1.common.spawner.configmapAndSecret" . | nindent 0 -}}

  {{- if .Values.controllers.main.enabled -}}
    {{- if eq .Values.controllers.main.type "Deployment" -}}
      {{- include "ix.v1.common.deployment" . | nindent 0 -}}
    {{- else if eq .Values.controllers.main.type "DaemonSet" -}}
      {{- include "ix.v1.common.daemonset" . | nindent 0 -}}
    {{- else if eq .Values.controllers.main.type "StatefulSet" -}}
      {{- include "ix.v1.common.statefulset" . | nindent 0 -}}
    {{- else if (mustHas .Values.controllers.main.type (list "Job" "CronJob")) -}}
      {{/* Pass, it will render from the spawner.jobAndCronJob bellow */}}
    {{- else -}}
      {{- fail (printf "Not a valid controller.type (%s). Valid options are Deployment, DaemonSet, StatefulSet, Job, CronJob" .Values.controllers.main.type) -}}
    {{- end -}}
  {{- end -}}

  {{- include "ix.v1.common.spawner.service" . | nindent 0 -}}

  {{- include "ix.v1.common.spawner.pvc" . | nindent 0 -}}

  {{- include "ix.v1.common.spawner.portal" . | nindent 0 -}}

  {{- include "ix.v1.common.spawner.jobAndCronJob" . | nindent 0 -}}

  {{- include "ix.v1.common.util.envCheckDupes" (dict "root" .) -}}

{{- end -}}
