{{/* CronJob Spec */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.workload.cronjobSpec" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the chart.
objectData:
  schedule: The schedule in Cron format, see https://en.wikipedia.org/wiki/Cron.
  concurrencyPolicy: Allow, Forbid, or Replace. Defaults to Allow.
  failedJobsHistoryLimit: The number of failed finished jobs to retain. Defaults to 1.
  successfulJobsHistoryLimit: The number of successful finished jobs to retain. Defaults to 3.
  startingDeadlineSeconds: Optional deadline in seconds for starting the job if it misses scheduled time for any reason. Defaults to nil.
  timezone: The timezone name. Defaults to .Values.TZ
  +jobSpec data
*/}}
{{- define "ix.v1.common.lib.workload.cronjobSpec" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}
timeZone: {{ (tpl ($objectData.timezone | default $rootCtx.Values.TZ) $rootCtx) | quote }}
schedule: {{ (tpl $objectData.schedule $rootCtx) | quote }}
concurrencyPolicy: {{ $objectData.concurrencyPolicy | default "Forbid" }}
failedJobsHistoryLimit: {{ $objectData.failedJobsHistoryLimit | default 1 }}
successfulJobsHistoryLimit: {{ $objectData.successfulJobsHistoryLimit | default 3 }}
startingDeadlineSeconds: {{ $objectData.startingDeadlineSeconds | default nil }}
jobTemplate:
  spec:
    {{- include "ix.v1.common.lib.workload.jobSpec" (dict "rootCtx" $rootCtx "objectData" $objectData) | nindent 4 }}
{{- end -}}
