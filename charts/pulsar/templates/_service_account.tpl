{{/*
Create service-account
*/}}
{{- define "pulsar.service-account" -}}
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ .Args.service_account | quote }}
  namespace: {{ template "pulsar.namespace" . }}
  labels:
    {{- include "pulsar.standardLabels" . | nindent 4 }}
    component: {{ .Args.component }}
  annotations:
    {{ .Args.annotations }}
automountServiceAccountToken: false
{{- end -}}


{{/*
Create service-account-configmap
*/}}
{{- define "pulsar.gcp.service-account-configmap" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Args.service_account_configmap | quote }}
  namespace: {{ template "pulsar.namespace" . }}
  labels:
    {{- include "pulsar.standardLabels" . | nindent 4 }}
    component: {{ .Args.component }}
  annotations:
data:
  sia_config: |
    {
      "version": "1.0.0",
      "domain":  "{{ .Values.athenz.domain }}",
      "service": {{ .Args.service_account | quote }},
      "drop_privileges": true
      {{ if and ( .Values.athenz.expiry_time) ( .Values.athenz.refresh_interval) }}
      , "expiry_time": {{ .Values.athenz.expiry_time }}
      , "refresh_interval": {{ .Values.athenz.refresh_interval }}
      {{ end }}
      {{ if .Args.sandns_wildcard }}
      , "sandns_wildcard": {{.Args.sandns_wildcard}}
      {{ end }}
    }
{{- end -}}
