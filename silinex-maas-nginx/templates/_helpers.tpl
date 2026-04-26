{{- define "silinex-maas-nginx.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-nginx.fullname" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-nginx.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-nginx.image" -}}
{{- $registry := .Values.global.imageRegistry | default "" | trimSuffix "/" -}}
{{- $repository := required "image.repository is required" .Values.image.repository | trimPrefix "/" -}}
{{- $tag := required "image.tag is required" (.Values.image.tag | default .Chart.AppVersion) -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
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

{{- define "silinex-maas-nginx.upstreamHost" -}}
{{- $host := .host | toString -}}
{{- if contains "." $host -}}
{{- $host -}}
{{- else -}}
{{- printf "%s.%s.svc.cluster.local" $host .root.Release.Namespace -}}
{{- end -}}
{{- end -}}
