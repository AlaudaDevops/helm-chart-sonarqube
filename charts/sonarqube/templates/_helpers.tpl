{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "sonarqube.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "sonarqube.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "sonarqube.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
  Create a default fully qualified mysql/postgresql name.
  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "postgresql.fullname" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Determine the hostname to use for PostgreSQL/mySQL.
*/}}
{{- define "postgresql.hostname" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s" .Values.postgresql.postgresqlServer -}}
{{- end -}}
{{- end -}}

{{/*
Determine the k8s secret containing the JDBC credentials
*/}}
{{- define "jdbc.secret" -}}
{{- if .Values.postgresql.enabled -}}
  {{- if .Values.postgresql.existingSecret -}}
  {{- .Values.postgresql.existingSecret -}}
  {{- else -}}
  {{- template "postgresql.fullname" . -}}
  {{- end -}}
{{- else if .Values.jdbcOverwrite.enable -}}
  {{- if .Values.jdbcOverwrite.jdbcSecretName -}}
  {{- .Values.jdbcOverwrite.jdbcSecretName -}}
  {{- else -}}
  {{- template "sonarqube.fullname" . -}}
  {{- end -}}
{{- else -}}
  {{- template "sonarqube.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Determine JDBC username
*/}}
{{- define "jdbc.username" -}}
{{- if and .Values.postgresql.enabled .Values.postgresql.postgresqlUsername -}}
  {{- .Values.postgresql.postgresqlUsername | quote -}}
{{- else if and .Values.jdbcOverwrite.enable .Values.jdbcOverwrite.jdbcUsername -}}
  {{- .Values.jdbcOverwrite.jdbcUsername | quote -}}
{{- else -}}
  {{- .Values.postgresql.postgresqlUsername -}}
{{- end -}}
{{- end -}}

{{/*
Determine the k8s secretKey contrining the JDBC password
*/}}
{{- define "jdbc.secretPasswordKey" -}}
{{- if .Values.postgresql.enabled -}}
  {{- if and .Values.postgresql.existingSecret .Values.postgresql.existingSecretPasswordKey -}}
  {{- .Values.postgresql.existingSecretPasswordKey -}}
  {{- else -}}
  {{- "postgres-password" -}}
  {{- end -}}
{{- else if .Values.jdbcOverwrite.enable -}}
  {{- if and .Values.jdbcOverwrite.jdbcSecretName .Values.jdbcOverwrite.jdbcSecretPasswordKey -}}
  {{- .Values.jdbcOverwrite.jdbcSecretPasswordKey -}}
  {{- else -}}
  {{- "jdbc-password" -}}
  {{- end -}}
{{- else -}}
  {{- "jdbc-password" -}}
{{- end -}}
{{- end -}}

{{/*
Determine JDBC password if internal secret is used
*/}}
{{- define "jdbc.internalSecretPasswd" -}}
{{- if .Values.jdbcOverwrite.enable -}}
  {{- .Values.jdbcOverwrite.jdbcPassword | b64enc | quote -}}
{{- else -}}
  {{- .Values.postgresql.postgresqlPassword | b64enc | quote -}}
{{- end -}}
{{- end -}}

{{/*
Set sonarqube.jvmOpts
*/}}
{{- define "sonarqube.jvmOpts" -}}
{{- if and .Values.caCerts.enabled .Values.prometheusExporter.enabled -}}
{{ printf "-javaagent:%s/data/jmx_prometheus_javaagent.jar=%d:%s/conf/prometheus-config.yaml -Djavax.net.ssl.trustStore=%s/certs/cacerts %s" .Values.sonarqubeFolder (int .Values.prometheusExporter.webBeanPort) .Values.sonarqubeFolder .Values.sonarqubeFolder .Values.jvmOpts | trim | quote }}
{{- else if .Values.caCerts.enabled -}}
{{ printf "-Djavax.net.ssl.trustStore=%s/certs/cacerts %s" .Values.sonarqubeFolder .Values.jvmOpts | trim | quote }}
{{- else if .Values.prometheusExporter.enabled -}}
{{ printf "-javaagent:%s/data/jmx_prometheus_javaagent.jar=%d:%s/conf/prometheus-config.yaml %s" .Values.sonarqubeFolder (int .Values.prometheusExporter.webBeanPort) .Values.sonarqubeFolder .Values.jvmOpts | trim | quote }}
{{- else -}}
{{ printf "%s" .Values.jvmOpts }}
{{- end -}}
{{- end -}}

{{/*
Set sonarqube.jvmCEOpts
*/}}
{{- define "sonarqube.jvmCEOpts" -}}
{{- if and .Values.caCerts.enabled .Values.prometheusExporter.enabled -}}
{{ printf "-javaagent:%s/data/jmx_prometheus_javaagent.jar=%d:%s/conf/prometheus-ce-config.yaml -Djavax.net.ssl.trustStore=%s/certs/cacerts %s" .Values.sonarqubeFolder (int .Values.prometheusExporter.ceBeanPort) .Values.sonarqubeFolder .Values.sonarqubeFolder .Values.jvmCeOpts | trim | quote }}
{{- else if .Values.caCerts.enabled -}}
{{ printf "-Djavax.net.ssl.trustStore=%s/certs/cacerts %s" .Values.sonarqubeFolder .Values.jvmCeOpts | trim | quote }}
{{- else if .Values.prometheusExporter.enabled -}}
{{ printf "-javaagent:%s/data/jmx_prometheus_javaagent.jar=%d:%s/conf/prometheus-ce-config.yaml %s" .Values.sonarqubeFolder (int .Values.prometheusExporter.ceBeanPort) .Values.sonarqubeFolder .Values.jvmCeOpts | trim | quote }}
{{- else -}}
{{ printf "%s" .Values.jvmCeOpts }}
{{- end -}}
{{- end -}}

{{/*
Set prometheusExporter.downloadURL
*/}}
{{- define "prometheusExporter.downloadURL" -}}
{{- if .Values.prometheusExporter.downloadURL -}}
{{ printf "%s" .Values.prometheusExporter.downloadURL }}
{{- else -}}
{{ printf "https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/%s/jmx_prometheus_javaagent-%s.jar" .Values.prometheusExporter.version .Values.prometheusExporter.version }}
{{- end -}}
{{- end -}}


{{/*
Create the name of the service account to use
*/}}
{{- define "sonarqube.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "sonarqube.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{- define "sonarqube.image" -}}
{{- printf "%s/%s:%s" .Values.global.registry.address .Values.global.images.sonarqube.repository .Values.global.images.sonarqube.tag -}}
{{- end -}}

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
