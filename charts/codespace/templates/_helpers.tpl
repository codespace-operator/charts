{{/*
================================================================================
BASE NAMING FUNCTIONS
================================================================================
*/}}
{{- define "codespace.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "codespace.fullname" -}}
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
================================================================================
COMPONENT NAMING FUNCTIONS
================================================================================
*/}}
{{- define "codespace.operator.name" -}}
{{- printf "%s-operator" (include "codespace.fullname" .) -}}
{{- end -}}

{{- define "codespace.server.name" -}}
{{- printf "%s-server" (include "codespace.fullname" .) -}}
{{- end -}}

{{/*
================================================================================
SERVICE ACCOUNT FUNCTIONS
================================================================================
*/}}
{{- define "codespace.serviceAccountName" -}}
{{- if .Values.operator.serviceAccount.create -}}
{{- default (include "codespace.operator.name" .) .Values.operator.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.operator.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "codespace.server.serviceAccountName" -}}
{{- if .Values.server.serviceAccount.create -}}
{{- default (include "codespace.server.name" .) .Values.server.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.server.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
================================================================================
SERVICE NAMING FUNCTIONS
================================================================================
*/}}
{{- define "codespace.server.serviceName" -}}
{{- $default := include "codespace.server.name" . -}}
{{- default $default .Values.server.service.name -}}
{{- end -}}

{{- define "codespace.metrics.serviceName" -}}
{{- $default := printf "%s-metrics" (include "codespace.operator.name" .) -}}
{{- default $default .Values.operator.metrics.service.name -}}
{{- end -}}

{{/*
================================================================================
RBAC HELPER FUNCTIONS
================================================================================
*/}}
{{- define "codespace.server.rbac.configMapName" -}}
{{- $default := printf "%s-rbac" (include "codespace.server.name" .) -}}
{{- default $default .Values.server.rbac.configMapName -}}
{{- end -}}

{{/*
================================================================================
LDAP HELPER FUNCTIONS
================================================================================
*/}}
{{- define "codespace.server.auth.providers.ldap.configMapName" -}}
{{- $default := printf "%s-ldap" (include "codespace.server.name" .) -}}
{{- default $default .Values.server.auth.providers.ldap.configMapName -}}
{{- end -}}

{{/*
================================================================================
STANDARD KUBERNETES LABELS (Applied to ALL resources)
================================================================================
These are the core Kubernetes recommended labels that should be on every resource
*/}}
{{- define "codespace.standardLabels" -}}
app.kubernetes.io/name: {{ include "codespace.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- end -}}

{{/*
================================================================================
HELM METADATA LABELS (Applied to ALL resources)
================================================================================
These provide Helm-specific metadata for tracking and management
*/}}
{{- define "codespace.helmLabels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
helm.sh/release: {{ .Release.Name }}
helm.sh/revision: {{ .Release.Revision | quote }}
{{- end -}}

{{/*
================================================================================
COMPLETE RESOURCE LABELS (Standard + Helm + Custom)
================================================================================
This combines all standard labels with any custom labels from values
*/}}
{{- define "codespace.labels" -}}
{{- $standardLabels := include "codespace.standardLabels" . | fromYaml -}}
{{- $helmLabels := include "codespace.helmLabels" . | fromYaml -}}
{{- $result := merge (dict) $standardLabels $helmLabels -}}
{{- with .Values.commonLabels }}
{{- $result = merge $result . -}}
{{- end }}
{{- toYaml $result -}}
{{- end -}}

{{/*
================================================================================
SELECTOR LABELS (Minimal set for matching pods to services/deployments)
================================================================================
These are immutable labels used for resource selection
*/}}
{{- define "codespace.selectorLabels" -}}
app.kubernetes.io/name: {{ .name }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- end -}}

{{/*
================================================================================
COMPONENT-SPECIFIC LABELS
================================================================================
These add component identification to the base labels
*/}}
{{- define "codespace.operator.labels" -}}
{{- $baseLabels := include "codespace.labels" . | fromYaml -}}
{{- $componentLabels := dict "app.kubernetes.io/component" "operator" -}}
{{- $result := merge (dict) $baseLabels $componentLabels -}}
{{- with .Values.operator.labels }}
{{- $result = merge $result . -}}
{{- end }}
{{- toYaml $result -}}
{{- end -}}

{{- define "codespace.server.labels" -}}
{{- $baseLabels := include "codespace.labels" . | fromYaml -}}
{{- $componentLabels := dict "app.kubernetes.io/component" "server" -}}
{{- $result := merge (dict) $baseLabels $componentLabels -}}
{{- with .Values.server.labels }}
{{- $result = merge $result . -}}
{{- end }}
{{- toYaml $result -}}
{{- end -}}

{{/*
================================================================================
POD LABELS (Includes selector labels + component labels + pod-specific)
================================================================================
*/}}
{{- define "codespace.operator.podLabels" -}}
{{- $selectorLabels := include "codespace.selectorLabels" (dict "name" (include "codespace.name" .) "root" .) | fromYaml -}}
{{- $componentLabels := include "codespace.operator.labels" . | fromYaml -}}
{{- $result := merge (dict) $selectorLabels $componentLabels -}}
{{- with .Values.podLabels }}
{{- $result = merge $result . -}}
{{- end }}
{{- with .Values.operator.podLabels }}
{{- $result = merge $result . -}}
{{- end }}
{{- toYaml $result -}}
{{- end -}}

{{- define "codespace.server.podLabels" -}}
{{- $selectorLabels := include "codespace.selectorLabels" (dict "name" (printf "%s-server" (include "codespace.name" .)) "root" .) | fromYaml -}}
{{- $componentLabels := include "codespace.server.labels" . | fromYaml -}}
{{- $result := merge (dict) $selectorLabels $componentLabels -}}
{{- with .Values.podLabels }}
{{- $result = merge $result . -}}
{{- end }}
{{- with .Values.server.podLabels }}
{{- $result = merge $result . -}}
{{- end }}
{{- toYaml $result -}}
{{- end -}}

{{/*
================================================================================
STANDARD ANNOTATIONS (Applied to ALL resources)
================================================================================
*/}}
{{- define "codespace.standardAnnotations" -}}
meta.helm.sh/release-name: {{ .Release.Name }}
meta.helm.sh/release-namespace: {{ .Release.Namespace }}
{{- end -}}

{{/*
================================================================================
COMPLETE RESOURCE ANNOTATIONS
================================================================================
*/}}
{{- define "codespace.annotations" -}}
{{- $standardAnnotations := include "codespace.standardAnnotations" . | fromYaml -}}
{{- $result := merge (dict) $standardAnnotations -}}
{{- with .Values.commonAnnotations }}
{{- $result = merge $result . -}}
{{- end }}
{{- if $result }}
{{- toYaml $result -}}
{{- end }}
{{- end -}}

{{/*
================================================================================
COMPONENT-SPECIFIC ANNOTATIONS
================================================================================
*/}}
{{- define "codespace.operator.annotations" -}}
{{- $baseAnnotations := include "codespace.annotations" . | fromYaml -}}
{{- $result := merge (dict) $baseAnnotations -}}
{{- with .Values.operator.annotations }}
{{- $result = merge $result . -}}
{{- end }}
{{- if $result }}
{{- toYaml $result -}}
{{- end }}
{{- end -}}

{{- define "codespace.server.annotations" -}}
{{- $baseAnnotations := include "codespace.annotations" . | fromYaml -}}
{{- $result := merge (dict) $baseAnnotations -}}
{{- with .Values.server.annotations }}
{{- $result = merge $result . -}}
{{- end }}
{{- if $result }}
{{- toYaml $result -}}
{{- end }}
{{- end -}}

{{/*
================================================================================
POD ANNOTATIONS
================================================================================
*/}}
{{- define "codespace.operator.podAnnotations" -}}
{{- $baseAnnotations := include "codespace.operator.annotations" . | fromYaml -}}
{{- $result := merge (dict) $baseAnnotations -}}
{{- with .Values.podAnnotations }}
{{- $result = merge $result . -}}
{{- end }}
{{- with .Values.operator.podAnnotations }}
{{- $result = merge $result . -}}
{{- end }}
{{- if $result }}
{{- toYaml $result -}}
{{- end }}
{{- end -}}

{{- define "codespace.server.podAnnotations" -}}
{{- $baseAnnotations := include "codespace.server.annotations" . | fromYaml -}}
{{- $result := merge (dict) $baseAnnotations -}}
{{- with .Values.podAnnotations }}
{{- $result = merge $result . -}}
{{- end }}
{{- with .Values.server.podAnnotations }}
{{- $result = merge $result . -}}
{{- end }}
{{- if $result }}
{{- toYaml $result -}}
{{- end }}
{{- end -}}

{{/*
================================================================================
SERVICE ANNOTATIONS (for specific service types)
================================================================================
*/}}
{{- define "codespace.server.serviceAnnotations" -}}
{{- $baseAnnotations := include "codespace.server.annotations" . | fromYaml -}}
{{- $result := merge (dict) $baseAnnotations -}}
{{- with .Values.server.service.annotations }}
{{- $result = merge $result . -}}
{{- end }}
{{- if $result }}
{{- toYaml $result -}}
{{- end }}
{{- end -}}

{{- define "codespace.metrics.serviceAnnotations" -}}
{{- $baseAnnotations := include "codespace.operator.annotations" . | fromYaml -}}
{{- $result := merge (dict) $baseAnnotations -}}
{{- with .Values.operator.metrics.service.annotations }}
{{- $result = merge $result . -}}
{{- end }}
{{- if $result }}
{{- toYaml $result -}}
{{- end }}
{{- end -}}