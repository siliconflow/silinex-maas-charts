{{- define "silinex-maas-frontend.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-frontend.fullname" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-frontend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-frontend.labels" -}}
helm.sh/chart: {{ include "silinex-maas-frontend.chart" . }}
{{ include "silinex-maas-frontend.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "silinex-maas-frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "silinex-maas-frontend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "silinex-maas-frontend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "silinex-maas-frontend.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "silinex-maas-frontend.secretName" -}}
{{- if .Values.secrets.existingSecret -}}
{{- .Values.secrets.existingSecret -}}
{{- else -}}
{{- default (printf "%s-secret" (include "silinex-maas-frontend.fullname" .)) .Values.secrets.name -}}
{{- end -}}
{{- end -}}
