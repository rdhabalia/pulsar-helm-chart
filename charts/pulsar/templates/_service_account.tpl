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
    eks.amazonaws.com/role-arn: {{ .Args.annotations }}
{{- end -}}


{{/*
Create service-account-configmap
*/}}
{{- define "pulsar.service-account-configmap" -}}
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
      "service": {{ .Args.service_account | quote }},
      "accounts": [
        {
          "domain":  "{{ .Values.athenz.domain }}",
          "account": "{{ .Values.athenz.aws_account_id }}"
        }
      ],
      "drop_privileges": true,
      {{ if and (not .Values.athenz.expiry_time) (not .Values.athenz.refresh_interval) }}
      "expiry_time": .Values.athenz.expiry_time,
      "refresh_interval": .Values.athenz.refresh_interval,
      {{ end }}
      {{ if .Args.sandns_wildcard }}
      "user": "appuser",
      "sandns_wildcard": true
      {{ else }}
      "user": "appuser"
      {{ end }}
    }
{{- end -}}