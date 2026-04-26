{{- define "silinex-maas-docs.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-docs.fullname" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-docs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-docs.image" -}}
{{- $registry := .Values.global.imageRegistry | default "" | trimSuffix "/" -}}
{{- $repository := required "image.repository is required" .Values.image.repository | trimPrefix "/" -}}
{{- $tag := required "image.tag is required" (.Values.image.tag | default .Chart.AppVersion) -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end -}}

{{- define "silinex-maas-docs.managementPlaneHost" -}}
{{- default "10.60.30.120" .Values.global.managementPlane.host -}}
{{- end -}}

{{- define "silinex-maas-docs.apiUrl" -}}
{{- printf "https://%s:%v" (include "silinex-maas-docs.managementPlaneHost" .) (default 31300 .Values.global.managementPlane.ports.aggregateHttps) -}}
{{- end -}}

{{- define "silinex-maas-docs.labels" -}}
helm.sh/chart: {{ include "silinex-maas-docs.chart" . }}
{{ include "silinex-maas-docs.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "silinex-maas-docs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "silinex-maas-docs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "silinex-maas-docs.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "silinex-maas-docs.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}
