{{- define "spire.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "spire.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "spire.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" -}}
{{- end -}}

{{- define "spire.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spire.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "spire.labels" -}}
helm.sh/chart: {{ include "spire.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{ include "spire.selectorLabels" . }}
{{- end -}}

{{- define "spire.server" -}}
{{ printf "%s-server" (include "spire.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "spire.agent" -}}
{{ printf "%s-agent" (include "spire.fullname" .) | trunc 63 | trimSuffix "-" }}
{{- end -}}

{{- define "spire.serverServiceAccountName" -}}
{{- if .Values.server.serviceAccount.create -}}
{{- default (include "spire.server" .) .Values.server.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.server.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "spire.agentServiceAccountName" -}}
{{- if .Values.agent.serviceAccount.create -}}
{{- default (include "spire.agent" .) .Values.agent.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.agent.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "spire.fqdn" -}}
{{ include "spire.server" . }}.{{ .Release.Namespace }}.svc.cluster.local
{{- end -}}
