{{/*
Create chart name and version as used by labels.
*/}}
{{- define "silinex-maas-server.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-server.image" -}}
{{- $registry := .Values.global.imageRegistry | default "" | trimSuffix "/" -}}
{{- $repository := required "image.repository is required" .Values.image.repository | trimPrefix "/" -}}
{{- $tag := required "image.tag is required" (.Values.image.tag | default .Chart.AppVersion) -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end -}}

{{- define "silinex-maas-server.serverName" -}}
{{- .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-server.initJobName" -}}
{{- .Values.initJob.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-maas-server.secretName" -}}
{{- if .Values.secrets.existingSecret -}}
{{- .Values.secrets.existingSecret -}}
{{- else -}}
{{- default (printf "%s-secret" (include "silinex-maas-server.serverName" .)) .Values.secrets.name -}}
{{- end -}}
{{- end -}}

{{- define "silinex-maas-server.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "silinex-maas-server.serverName" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "silinex-maas-server.labels" -}}
helm.sh/chart: {{ include "silinex-maas-server.chart" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "silinex-maas-server.serverSelectorLabels" -}}
app.kubernetes.io/name: {{ include "silinex-maas-server.serverName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: server
{{- end -}}

{{- define "silinex-maas-server.initSelectorLabels" -}}
app.kubernetes.io/name: {{ include "silinex-maas-server.initJobName" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: init
{{- end -}}

{{- define "silinex-maas-server.serverDsn" -}}
{{- if .Values.postgres.serverDsnOverride -}}
{{- .Values.postgres.serverDsnOverride -}}
{{- else -}}
{{- printf "host=%s user=%s password=%s dbname=%s port=%v sslmode=%s TimeZone=%s" (.Values.postgres.host | toString) (.Values.postgres.user | toString) (.Values.postgres.password | toString) (.Values.postgres.serverDatabase | toString) .Values.postgres.port (.Values.postgres.sslmode | toString) (.Values.postgres.timezone | toString) -}}
{{- end -}}
{{- end -}}

{{- define "silinex-maas-server.logtoManagementDsn" -}}
{{- if .Values.postgres.logtoManagementDsnOverride -}}
{{- .Values.postgres.logtoManagementDsnOverride -}}
{{- else -}}
{{- printf "host=%s user=%s password=%s dbname=%s port=%v sslmode=%s TimeZone=%s" (.Values.postgres.host | toString) (.Values.postgres.user | toString) (.Values.postgres.password | toString) (.Values.postgres.logtoDatabase | toString) .Values.postgres.port (.Values.postgres.sslmode | toString) (.Values.postgres.timezone | toString) -}}
{{- end -}}
{{- end -}}

{{- define "silinex-maas-server.redisSentinelAddrs" -}}
{{- if kindIs "slice" .Values.redis.sentinelAddrs -}}
{{- join "," .Values.redis.sentinelAddrs -}}
{{- else -}}
{{- .Values.redis.sentinelAddrs -}}
{{- end -}}
{{- end -}}
