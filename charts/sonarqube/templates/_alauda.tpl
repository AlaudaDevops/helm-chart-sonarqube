{{- define "sonarqube.image" -}}
{{- printf "%s/%s:%s" .Values.global.registry.address .Values.global.images.sonarqube.repository .Values.global.images.sonarqube.tag -}}
{{- end -}}

{{- define "initSysctl.image" -}}
{{- printf "%s/%s:%s" .Values.global.registry.address .Values.global.images.busybox.repository .Values.global.images.busybox.tag -}}
{{- end -}}

{{- define "plugins.image" -}}
{{- printf "%s/%s:%s" .Values.global.registry.address .Values.global.images.pluginPackage.repository .Values.global.images.pluginPackage.tag -}}
{{- end -}}

{{- define "wget.image" -}}
{{- printf "%s/%s:%s" .Values.global.registry.address .Values.global.images.busybox.repository .Values.global.images.busybox.tag -}}
{{- end -}}

{{- define "waitdb.image" -}}
{{- printf "%s/%s:%s" .Values.global.registry.address .Values.global.images.busybox.repository .Values.global.images.busybox.tag -}}
{{- end -}}

{{- define "sonarqube.odic.providerConfiguration" -}}
{{- printf "{\"issuer\":\"%s\",\"authorization_endpoint\":\"%s/auth\",\"token_endpoint\":\"%s/token\",\"jwks_uri\":\"%s/keys\",\"response_types_supported\":%s,\"subject_types_supported\":%s,\"id_token_signing_alg_values_supported\":%s,\"scopes_supported\":%s,\"token_endpoint_auth_methods_supported\":%s,\"claims_supported\":%s}"  .Values.oidc.issuer  .Values.oidc.issuer  .Values.oidc.issuer .Values.oidc.issuer  .Values.oidc.sonarqube.response_types_supported  .Values.oidc.sonarqube.subject_types_supported .Values.oidc.sonarqube.id_token_signing_alg_values_supported .Values.oidc.scope .Values.oidc.sonarqube.token_endpoint_auth_methods_supported .Values.oidc.sonarqube.claims_supported -}}
{{- end -}}

{{- define "preupgrade.name" -}}
{{ (printf "%s-pre-migration" (include "sonarqube.fullname" .) | trunc 63) | trimSuffix "-" }}
{{- end -}}
