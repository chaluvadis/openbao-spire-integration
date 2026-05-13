{{- define "spire.name" -}}
{{ .Release.Name }}-spire
{{- end -}}

{{- define "spire.server.name" -}}
{{ include "spire.name" . }}-server
{{- end -}}

{{- define "spire.agent.name" -}}
{{ include "spire.name" . }}-agent
{{- end -}}