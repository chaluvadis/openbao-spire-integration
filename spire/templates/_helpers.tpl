{{/*
Expand the name of the chart.
*/}}
{{- define "spire.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "spire.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "spire.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "spire.labels" -}}
helm.sh/chart: {{ include "spire.chart" . }}
{{ include "spire.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels (shared base)
*/}}
{{- define "spire.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spire.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Server-specific helper names
*/}}
{{- define "spire.server" -}}
{{- include "spire.fullname" . }}-server
{{- end }}

{{/*
Agent-specific helper names
*/}}
{{- define "spire.agent" -}}
{{- include "spire.fullname" . }}-agent
{{- end }}

{{/*
FQDN of the SPIRE server service
*/}}
{{- define "spire.fqdn" -}}
{{ include "spire.server" . }}.{{ .Release.Namespace }}.svc.cluster.local
{{- end }}

{{/*
Server selector labels
*/}}
{{- define "spire.server.selectorLabels" -}}
{{ include "spire.selectorLabels" . }}
app.kubernetes.io/component: server
{{- end }}

{{/*
Agent selector labels
*/}}
{{- define "spire.agent.selectorLabels" -}}
{{ include "spire.selectorLabels" . }}
app.kubernetes.io/component: agent
{{- end }}

{{/*
Server service account name
*/}}
{{- define "spire.server.serviceAccountName" -}}
{{- if .Values.server.serviceAccount.create }}
{{- default (include "spire.server" .) .Values.server.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.server.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Agent service account name
*/}}
{{- define "spire.agent.serviceAccountName" -}}
{{- if .Values.agent.serviceAccount.create }}
{{- default (include "spire.agent" .) .Values.agent.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.agent.serviceAccount.name }}
{{- end }}
{{- end }}