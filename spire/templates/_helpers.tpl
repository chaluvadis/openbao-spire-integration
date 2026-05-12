{{- define "spire.name" -}}
{{ .Release.Name }}
{{- end }}

{{- define "spire.server" -}}
{{ .Release.Name }}-server
{{- end }}

{{- define "spire.agent" -}}
{{ .Release.Name }}-agent
{{- end }}

{{- define "spire.fqdn" -}}
{{ include "spire.server" . }}.{{ .Release.Namespace }}.svc.cluster.local
{{- end }}