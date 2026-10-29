{{/* Etiquetas comunes recomendadas (app.kubernetes.io/*) */}}
{{- define "tienda.etiquetas" -}}
app.kubernetes.io/name: tienda
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end }}

{{/* Selector de un componente: estable, nunca incluye la versión */}}
{{- define "tienda.selector" -}}
app.kubernetes.io/name: tienda
app.kubernetes.io/instance: {{ .raiz.Release.Name }}
app.kubernetes.io/component: {{ .componente }}
{{- end }}

{{- define "tienda.imagen" -}}
{{ .raiz.Values.imagen.registro }}/tienda-{{ .componente }}:{{ .etiqueta | default .raiz.Chart.AppVersion }}
{{- end }}

{{/* Contexto de seguridad del pod y del contenedor: cumple Pod Security "restricted" */}}
{{- define "tienda.podSeguro" -}}
runAsNonRoot: true
seccompProfile:
  type: RuntimeDefault
{{- end }}

{{- define "tienda.contenedorSeguro" -}}
allowPrivilegeEscalation: false
readOnlyRootFilesystem: true
capabilities:
  drop: ["ALL"]
{{- end }}
