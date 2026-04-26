{{- define "silinex-model-downloader.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-model-downloader.fullname" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-model-downloader.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-model-downloader.labels" -}}
helm.sh/chart: {{ include "silinex-model-downloader.chart" . }}
{{ include "silinex-model-downloader.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "silinex-model-downloader.selectorLabels" -}}
app.kubernetes.io/name: {{ include "silinex-model-downloader.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "silinex-model-downloader.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "silinex-model-downloader.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "silinex-model-downloader.secretName" -}}
{{- if .Values.secrets.existingSecret -}}
{{- .Values.secrets.existingSecret -}}
{{- else -}}
{{- default (printf "%s-secret" (include "silinex-model-downloader.fullname" .)) .Values.secrets.name -}}
{{- end -}}
{{- end -}}

{{- define "silinex-model-downloader.pvcName" -}}
{{- if .Values.persistence.existingClaim -}}
{{- .Values.persistence.existingClaim -}}
{{- else -}}
{{- .Values.persistence.pvcName -}}
{{- end -}}
{{- end -}}
