{{/*
Return the full name of the release
*/}}
{{- define "currency-converter.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
