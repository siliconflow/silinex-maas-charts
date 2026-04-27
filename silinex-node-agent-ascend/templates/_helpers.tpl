{{/*
Expand the name of the chart.
*/}}
{{- define "silinex-node-agent-ascend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "silinex-node-agent-ascend.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "silinex-node-agent-ascend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-node-agent-ascend.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride -}}
{{- end -}}

{{- define "silinex-node-agent-ascend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "silinex-node-agent-ascend.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "silinex-node-agent-ascend.clusterRoleName" -}}
{{- default (printf "%s-annotator" (include "silinex-node-agent-ascend.fullname" .)) .Values.rbac.clusterRoleName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-node-agent-ascend.clusterRoleBindingName" -}}
{{- default (printf "%s-annotator-binding" (include "silinex-node-agent-ascend.fullname" .)) .Values.rbac.clusterRoleBindingName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "silinex-node-agent-ascend.daemonSetName" -}}
{{- $root := .root -}}
{{- $arch := .arch | default "" -}}
{{- $base := include "silinex-node-agent-ascend.fullname" $root -}}
{{- if $arch -}}
{{- printf "%s-%s" $base $arch | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $base -}}
{{- end -}}
{{- end -}}

{{- define "silinex-node-agent-ascend.image" -}}
{{- $root := .root -}}
{{- $repository := required "image.repository is required" (default $root.Values.image.repository .repository) | trimPrefix "/" -}}
{{- $tag := required "image.tag is required" (default $root.Values.image.tag .tag) -}}
{{- $registry := $root.Values.global.imageRegistry | default "" | trimSuffix "/" -}}
{{- if $registry -}}
{{- printf "%s/%s:%s" $registry $repository $tag -}}
{{- else -}}
{{- printf "%s:%s" $repository $tag -}}
{{- end -}}
{{- end -}}

{{- define "silinex-node-agent-ascend.labels" -}}
helm.sh/chart: {{ include "silinex-node-agent-ascend.chart" . }}
app.kubernetes.io/name: {{ include "silinex-node-agent-ascend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: ascend-agent
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "silinex-node-agent-ascend.selectorLabels" -}}
{{- $root := .root -}}
app.kubernetes.io/name: {{ include "silinex-node-agent-ascend.name" $root }}
app.kubernetes.io/instance: {{ $root.Release.Name }}
app.kubernetes.io/component: ascend-agent
{{- with .arch }}
app.kubernetes.io/arch: {{ . | quote }}
{{- end }}
{{- end -}}
