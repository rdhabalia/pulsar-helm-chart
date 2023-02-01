{{/*
Create init-sia container
*/}}
{{- define "pulsar.init-sia" -}}
- name: init-sia
  image: "{{ .Values.images.sia.repository }}/{{ .Values.images.sia.tag }}"
  imagePullPolicy: {{ .Values.images.sia.pullPolicy }}
  command: ['sh', '-c', "while :; do /usr/sbin/siad -regionalsts -cmd post && break; done"]
  securityContext:
{{ toYaml .Values.container.securityContext | indent 4 }}
  resources:
{{ toYaml .Values.athenz.sia.resources | indent 4 }}
  volumeMounts:
{{ toYaml .Values.athenz.sia.init_volumeMounts | indent 4 }}
{{- end }}

{{/*
Create init-cameo container
*/}}
{{- define "pulsar.init-cameo" -}}
- name: init-cameo
  image: "{{ .Values.images.cameo.repository }}/{{ .Values.images.cameo.tag }}"
  imagePullPolicy: {{ .Values.images.cameo.pullPolicy }}
  securityContext:
{{ toYaml .Values.container.securityContext | indent 4 }}
  env:
{{ toYaml .Values.athenz.cameo.env | indent 4 }}
    - name: ATHENZ_SERVICE_CERT_PATH
      value: {{ .Values.athenz.certs.path }}/{{ .Values.athenz.domain }}.{{ .Args.service_account }}.cert.pem
    - name: ATHENZ_SERVICE_KEY_PATH
      value: {{ .Values.athenz.certs.key }}/{{ .Values.athenz.domain }}.{{ .Args.service_account }}.key.pem
    - name: INIT_RUN
      value: "true"
  resources:
{{ toYaml .Values.athenz.cameo.resources | indent 4 }}
  volumeMounts:
{{ toYaml .Values.athenz.volumeMounts | indent 4 }}
{{- end }}

{{/*
Create sia container
*/}}
{{- define "pulsar.sia" -}}
- name: sia
  image: "{{ .Values.images.sia.repository }}/{{ .Values.images.sia.tag }}"
  imagePullPolicy: {{ .Values.images.sia.pullPolicy }}
  securityContext:
{{ toYaml .Values.container.securityContext | indent 4 }}
  resources:
{{ toYaml .Values.athenz.sia.resources | indent 4 }}
  volumeMounts:
{{ toYaml .Values.athenz.sia.volumeMounts | indent 4 }}
{{- end }}


{{/*
Create cameo container
*/}}
{{- define "pulsar.cameo" -}}
- name: cameo
  image: "{{ .Values.images.cameo.repository }}/{{ .Values.images.cameo.tag }}"
  imagePullPolicy: {{ .Values.images.cameo.pullPolicy }}
  securityContext:
{{ toYaml .Values.container.securityContext | indent 4 }}
  resources:
{{ toYaml .Values.athenz.cameo.resources | indent 4 }}
  volumeMounts:
{{ toYaml .Values.athenz.volumeMounts | indent 4 }}
  env:
{{ toYaml .Values.athenz.cameo.env | indent 4 }}
    - name: ATHENZ_SERVICE_CERT_PATH
      value: {{ .Values.athenz.certs.path }}/{{ .Values.athenz.domain }}.{{ .Args.service_account }}.cert.pem
    - name: ATHENZ_SERVICE_KEY_PATH
      value: {{ .Values.athenz.certs.key }}/{{ .Values.athenz.domain }}.{{ .Args.service_account }}.key.pem
{{- end -}}


{{/*
Create sia volumes
*/}}
{{- define "pulsar.sia-volumes" -}}
{{ toYaml .Values.athenz.volumes }}
- name: sia
  configMap:
    name: {{ .Args.service_account_configmap | quote }}
{{ toYaml .Values.athenz.sia.config_map | indent 4 }}
{{- end -}}