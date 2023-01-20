{{- define "gitlab.checkConfig.nginx.controller.extraArgs" -}}
{{-   if (index $.Values "nginx-ingress").enabled -}}
{{-     if hasKey (index $.Values "nginx-ingress").controller.extraArgs "force-namespace-isolation" -}}
nginx-ingress:
  `nginx-ingress.controller.extraArgs.force-namespace-isolation` was previously set by default in the GitLab chart's values.yaml file,
  but has since been deprecated upon the upgrade to NGINX 0.41.2 (upstream chart version 3.11.1).
  Please remove the `force-namespace-isolation` key.
{{-     end -}}
{{-   end -}}
{{- end -}}
{{/* END "gitlab.checkConfig.nginx.controller" */}}

{{- define "gitlab.checkConfig.nginx.clusterrole.scope" -}}
{{-   if (index $.Values "nginx-ingress").rbac.scope -}}
nginx-ingress:
  'rbac.scope' should be false. Namespaced IngressClasses do not exist.
  See https://github.com/kubernetes/ingress-nginx/issues/7519
{{-   end -}}
{{- end -}}
{{/* END "gitlab.checkConfig.nginx.clusterrole" */}}
