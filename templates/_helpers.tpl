{{/*
Expand the name of the chart.
*/}}
{{- define "arangodb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "arangodb.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}


{{/*
The full name of the agent
*/}}
{{- define "arangodb.agent.fullname" -}}
{{- printf "%s-agent" (include "arangodb.fullname" .) }}
{{- end }}

{{/*
The full name of the coordinator
*/}}
{{- define "arangodb.coordinator.fullname" -}}
{{- printf "%s-coordinator" (include "arangodb.fullname" .) }}
{{- end }}


{{/*
The full name of the dbserver
*/}}
{{- define "arangodb.dbserver.fullname" -}}
{{- if eq .Values.mode "single" }}
{{- printf "%s-single" (include "arangodb.fullname" .) }}
{{- else }}
{{- printf "%s-dbserver" (include "arangodb.fullname" .) }}
{{- end }}
{{- end }}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "arangodb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "arangodb.dbserver.labels" -}}
helm.sh/chart: {{ include "arangodb.chart" . }}
{{ include "arangodb.dbserver.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "arangodb.dbserver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "arangodb.name" . }}
app.kubernetes.io/component: dbserver
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "arangodb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "arangodb.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
imagePullSecrets generates pull secrets from either string or map values.
A map value must be indexable by the key 'name'.
*/}}
{{- define "imagePullSecrets" -}}
{{- with .Values.imagePullSecrets -}}
imagePullSecrets:
{{- range . -}}
{{- if typeIs "string" . }}
  - name: {{ . }}
{{- else if index . "name" }}
  - name: {{ .name }}
{{- end }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
The name JWT token name
*/}}
{{- define "arangodb.jwtSecret.secretName" -}}
{{- if .Values.auth.jwtSecret.secretName }}
{{- .Values.auth.jwtSecret.secretName }}
{{- else }}
{{- printf "%s-jwt" (include "arangodb.fullname" .) }}
{{- end }}
{{- end }}

{{/*
The path of the jwt secret
*/}}
{{- define "arangodb.jwtSecret.path" -}}
{{- if .Values.auth.jwtSecret.existingFile }}
{{- .Values.auth.jwtSecret.existingFile }}
{{- else }}
{{- "/secrets/cluster/jwt/token" }}
{{- end }}
{{- end }}


{{- define "arangodb.jwtSecret.mountPath" -}}
{{- "/secrets/cluster/jwt" }}
{{- end }}
{{/*
Common labels
*/}}
{{- define "arangodb.agent.labels" -}}
helm.sh/chart: {{ include "arangodb.chart" . }}
{{ include "arangodb.agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "arangodb.agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "arangodb.name" . }}
app.kubernetes.io/component: agent
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "arangodb.coordinator.labels" -}}
helm.sh/chart: {{ include "arangodb.chart" . }}
{{ include "arangodb.coordinator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "arangodb.coordinator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "arangodb.name" . }}
app.kubernetes.io/component: coordinator
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Common labels
*/}}
{{- define "arangodb.haproxy.labels" -}}
helm.sh/chart: {{ include "arangodb.chart" . }}
{{ include "arangodb.haproxy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "arangodb.haproxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "arangodb.name" . }}
app.kubernetes.io/component: haproxy
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{- define "arangodb.common.volumes" -}}
{{- if or .Values.auth.jwtSecret.secretName (and (not .Values.auth.jwtSecret.secretName) .Values.auth.jwtSecret.create) -}}
- name: cluster-jwt
  secret:
    defaultMode: 420
    secretName: {{ include "arangodb.jwtSecret.secretName" . }}
{{- end -}}
{{ if .Values.global.volumes }}
{{ toYaml .Values.global.volumes }}
{{- end -}}
{{- end -}}

{{/*
Additional container volume mounts for the dbserver pods
*/}}
{{- define "arangodb.common.mounts" -}}
{{- if or .Values.auth.jwtSecret.secretName (and (not .Values.auth.jwtSecret.secretName) .Values.auth.jwtSecret.create) }}
- mountPath: {{ include "arangodb.jwtSecret.mountPath" . }}
  name: cluster-jwt
{{- end -}}
{{- if .Values.global.volumeMounts }}
{{ toYaml .Values.global.volumeMounts }}
{{- end -}}
{{- end -}}


{{/*
Volumes for the dbserver pods
*/}}
{{- define "arangodb.dbserver.volumes" -}}
{{ template "arangodb.common.volumes" . }}
{{- end -}}

{{/*
Volumes for the coordinator pods
*/}}
{{- define "arangodb.coordinator.volumes" -}}
{{ template "arangodb.common.volumes" . }}
{{- end -}}

{{/*
Volumes for the agent pods
*/}}
{{- define "arangodb.agent.volumes" -}}
{{ template "arangodb.common.volumes" . }}
{{- end -}}


{{/*
Additional container volume mounts for the dbserver pods
*/}}
{{- define "arangodb.dbserver.mounts" -}}
{{ template "arangodb.common.mounts" . }}
{{- end -}}

{{/*
Additional container volume mounts for the coordinator pods
*/}}
{{- define "arangodb.coordinator.mounts" -}}
{{ template "arangodb.common.mounts" . }}
{{- end -}}

{{/*
Additional container volume mounts for the agent pods
*/}}
{{- define "arangodb.agent.mounts" -}}
{{ template "arangodb.common.mounts" . }}
{{- end -}}
