{{/*
Create pod monitor
*/}}
{{- define "pulsar.pod-monitor" -}}
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: {{ template "pulsar.name" . }}-{{ .Args.component }}
  labels:
    app: {{ template "pulsar.name" . }}
    chart: {{ template "pulsar.chart" . }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
spec:
  jobLabel: {{ .Args.component }}
  podMetricsEndpoints:
    - port: http
      path: /metrics
      scheme: http
      interval: {{ .Args.interval }}
      scrapeTimeout: {{ .Args.scrapeTimeout }}
      relabelings:
        - action: labelmap
          regex: __meta_kubernetes_pod_label_(.+)
        - sourceLabels: [__meta_kubernetes_namespace]
          action: replace
          targetLabel: kubernetes_namespace
        - sourceLabels: [__meta_kubernetes_pod_label_component]
          action: replace
          targetLabel: job
        - sourceLabels: [__meta_kubernetes_pod_name]
          action: replace
          targetLabel: kubernetes_pod_name
  selector:
    matchLabels:
      {{- include "pulsar.matchLabels" . | nindent 6 }}
      component: {{ .Args.component }}
{{- end }}