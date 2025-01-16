{{- define "initSysctl.image" -}}
{{- printf "%s/%s:%s" .Values.global.registry.address .Values.global.images.initSysctl.repository .Values.global.images.initSysctl.tag -}}
{{- end -}}

{{- define "plugins.image" -}}
{{- printf "%s/%s:%s" .Values.global.registry.address .Values.global.images.pluginPackage.repository .Values.global.images.pluginPackage.tag -}}
{{- end -}}

{{- define "wget.image" -}}
{{- printf "%s/%s:%s" .Values.global.registry.address .Values.global.images.wget.repository .Values.global.images.wget.tag -}}
{{- end -}}

{{- define "waitdb.image" -}}
{{- printf "%s/%s:%s" .Values.global.registry.address .Values.global.images.waitdb.repository .Values.global.images.waitdb.tag -}}
{{- end -}}

{{- define "sonarqube.odic.providerConfiguration" -}}
{{- printf "{\"issuer\":\"%s\",\"authorization_endpoint\":\"%s/auth\",\"token_endpoint\":\"%s/token\",\"jwks_uri\":\"%s/keys\",\"response_types_supported\":%s,\"subject_types_supported\":%s,\"id_token_signing_alg_values_supported\":%s,\"scopes_supported\":%s,\"token_endpoint_auth_methods_supported\":%s,\"claims_supported\":%s}"  .Values.oidc.issuer  .Values.oidc.issuer  .Values.oidc.issuer .Values.oidc.issuer  .Values.oidc.sonarqube.response_types_supported  .Values.oidc.sonarqube.subject_types_supported .Values.oidc.sonarqube.id_token_signing_alg_values_supported .Values.oidc.scope .Values.oidc.sonarqube.token_endpoint_auth_methods_supported .Values.oidc.sonarqube.claims_supported -}}
{{- end -}}

{{- define "preupgrade.name" -}}
{{ (printf "%s-pre-migration" (include "sonarqube.fullname" .) | trunc 63) | trimSuffix "-" }}
{{- end -}}

{{- define "sonarqube.admin.password" -}}
{{- if and .Values.account .Values.account.adminPassword -}}
  {{- .Values.account.adminPassword | quote -}}
{{- else -}}
  {{- randAlphaNum 48 | cat (randAscii 8) | replace " " "" | shuffle | join "" | substr 0 48 | quote -}}
{{- end -}}
{{- end -}}
