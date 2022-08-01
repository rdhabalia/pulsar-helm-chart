{{/*
Define the pulsar brroker service
*/}}
{{- define "pulsar.adminproxy.service" -}}
{{ template "pulsar.fullname" . }}-{{ .Values.adminproxy.component }}
{{- end }}

{{/*
Define adminproxy tls certs mounts
*/}}
{{- define "pulsar.adminproxy.certs.volumeMounts" -}}
{{- if and .Values.tls.enabled (or .Values.tls.adminproxy.enabled (or .Values.tls.broker.enabled (or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled))) }}
- name: adminproxy-certs
  mountPath: "/pulsar/certs/adminproxy"
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
Define adminproxy tls certs volumes
*/}}
{{- define "pulsar.adminproxy.certs.volumes" -}}
{{- if and .Values.tls.enabled (or .Values.tls.adminproxy.enabled (or .Values.tls.broker.enabled (or .Values.tls.bookie.enabled .Values.tls.zookeeper.enabled))) }}
- name: adminproxy-certs
  secret:
    secretName: "{{ .Release.Name }}-{{ .Values.tls.adminproxy.cert_name }}"
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
