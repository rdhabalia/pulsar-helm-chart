{{/*
Define the pulsar toolset service
*/}}
{{- define "pulsar.toolset.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.toolset.component }}
{{- end }}

{{/*
Define the toolset hostname
*/}}
{{- define "pulsar.toolset.hostname" -}}
${HOSTNAME}.{{ template "pulsar.toolset.service" . }}.{{ template "pulsar.namespace" . }}.svc.{{ .Values.clusterDomain }}
{{- end -}}

{{/*
Define toolset zookeeper client tls settings
*/}}
{{- define "pulsar.toolset.zookeeper.tls.settings" -}}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled -}}
/pulsar/keytool/keytool.sh toolset {{ template "pulsar.toolset.hostname" . }} true;
{{- end -}}
{{- end }}

{{/*
Define toolset tls certs mounts
*/}}
{{- define "pulsar.toolset.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
- name: toolset-certs
  mountPath: "/pulsar/certs/toolset"
  readOnly: true
- name: ca
  mountPath: "/pulsar/certs/ca"
  readOnly: true
{{- if .Values.tls.zookeeper.enabled }}
- name: keytool
  mountPath: "/pulsar/keytool/keytool.sh"
  subPath: keytool.sh
{{- end }}
{{- end }}
{{- end }}

{{/*
Define toolset tls certs volumes
*/}}
{{- define "pulsar.toolset.certs.volumes" -}}
{{ if .Values.auth.authentication.enabled }}
{{ if eq .Values.auth.authentication.provider "athenz" }}
- name: tls-certs
  emptyDir:
    medium: {{ .Values.auth.authentication.athenz.certs.tls_certs.medium }}
- name: sia-volume
  emptyDir:
    medium: {{ .Values.auth.authentication.athenz.certs.sia_volume.medium }}
- name: sia
  configMap:
    name: "{{ .Values.bookkeeper.service_account.configmap }}"
    items:
    - key: {{ .Values.auth.authentication.athenz.certs.sia_config.key.name }}
      path: {{ .Values.auth.authentication.athenz.certs.sia_config.key.path }}
{{ end }}
{{ end }}
{{- if and .Values.tls.enabled .Values.tls.zookeeper.enabled }}
- name: toolset-certs
  secret:
    secretName: "{{ .Release.Name }}-{{ .Values.tls.toolset.cert_name }}"
    items:
    - key: tls.crt
      path: tls.crt
    - key: tls.key
      path: tls.key
- name: ca
  secret:
    secretName: "{{ .Release.Name }}-{{ .Values.tls.ca_suffix }}"
    items:
    - key: ca.crt
      path: ca.crt
{{- if .Values.tls.zookeeper.enabled }}
- name: keytool
  configMap:
    name: "{{ template "pulsar.fullname" . }}-keytool-configmap"
    defaultMode: 0755
{{- end }}
{{- end }}
{{- end }}
