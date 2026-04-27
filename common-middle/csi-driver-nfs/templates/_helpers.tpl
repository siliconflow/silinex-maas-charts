{{/* vim: set filetype=mustache: */}}

{{/* Expand the name of the chart.*/}}
{{- define "nfs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* labels for helm resources */}}
{{- define "nfs.labels" -}}
labels:
  app.kubernetes.io/instance: "{{ .Release.Name }}"
  app.kubernetes.io/managed-by: "{{ .Release.Service }}"
  app.kubernetes.io/name: "{{ template "nfs.name" . }}"
  app.kubernetes.io/version: "{{ .Chart.AppVersion }}"
  helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
  {{- if .Values.customLabels }}
{{ toYaml .Values.customLabels | indent 2 -}}
  {{- end }}
{{- end -}}

{{/* Build image from global.imageRegistry and the image repository path. */}}
{{- define "nfs.image" -}}
{{- $root := .root -}}
{{- $image := .image -}}
{{- $repository := required "image repository is required" $image.repository | trimPrefix "/" -}}
{{- $registry := required "global.imageRegistry is required" $root.Values.global.imageRegistry | trimSuffix "/" -}}
{{- printf "%s/%s:%s" $registry $repository $image.tag -}}
{{- end -}}
