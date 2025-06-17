{{- define "proyecto-kubernetes.fullname" -}}
{{ printf "%s" .Chart.Name }}
{{- end }}

{{- define "proyecto-kubernetes.name" -}}
{{ .Chart.Name }}
{{- end }}