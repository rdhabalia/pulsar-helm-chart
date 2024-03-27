{{/*
Create init-sia container
*/}}
{{- define "pulsar.gcp.init-sia" -}}
- name: init-sia
  image: "{{ .Values.images.sia.repository }}/{{ .Values.images.sia.tag }}"
  imagePullPolicy: {{ .Values.images.sia.pullPolicy }}
  command: ['/bin/sh', '-c']
  args:
    - /usr/sbin/siad -cmd register || exit 1;
      /usr/sbin/siad -cmd rolecert;
      /usr/sbin/siad -cmd token;
  securityContext:
{{ toYaml .Values.athenz.container.securityContext | indent 4 }}
  env:
    - name: ATHENZ_GKE_OMEGA_SUFFIX
      value: "1"
    - name: ATHENZ_GKE_OMEGA_CLUSTER
      value: "{{ .Values.omega.cluster }}-{{ .Values.omega.clusterColo }}"
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
{{ toYaml .Values.athenz.container.securityContext | indent 4 }}
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
{{- define "pulsar.gcp.sia" -}}
- name: sia
  image: "{{ .Values.images.sia.repository }}/{{ .Values.images.sia.tag }}"
  imagePullPolicy: {{ .Values.images.sia.pullPolicy }}
  securityContext:
{{ toYaml .Values.athenz.container.securityContext | indent 4 }}
  env:
    - name: ATHENZ_GKE_OMEGA_SUFFIX
      value: "1"
    - name: ATHENZ_GKE_OMEGA_CLUSTER
      value: {{ .Values.omega.cluster }}-{{ .Values.omega.clusterColo }}
    - name: ATHENZ_SIA_POD_NAMESPACE
      valueFrom:
        fieldRef:
          fieldPath: metadata.namespace
    - name: ATHENZ_SIA_POD_HOSTNAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    - name: ATHENZ_SIA_POD_SUBDOMAIN
      valueFrom:
        fieldRef:
          fieldPath: spec.serviceAccountName
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
{{ toYaml .Values.athenz.container.securityContext | indent 4 }}
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
    - name: SLEEP_DAYS
      value: "1"
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
