{{- define "silinex-maas-nginx.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-nginx.fullname" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-nginx.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-nginx.labels" -}}
helm.sh/chart: {{ include "silinex-maas-nginx.chart" . }}
{{ include "silinex-maas-nginx.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "silinex-maas-nginx.selectorLabels" -}}
app.kubernetes.io/name: {{ include "silinex-maas-nginx.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "silinex-maas-nginx.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "silinex-maas-nginx.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "silinex-maas-nginx.tlsSecretName" -}}
{{- default (printf "%s-tls" (include "silinex-maas-nginx.fullname" .)) .Values.tls.secretName -}}
{{- end -}}
