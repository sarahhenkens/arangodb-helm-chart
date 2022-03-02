{{- define "config-haproxy.cfg" }}
    defaults
      mode http
      timeout connect 4s
      timeout server 330s
      timeout client 330s
      timeout check 2s

    resolvers dnsserver
      parse-resolv-conf
      accepted_payload_size 8192
      hold valid 5s

    listen health_check_http_url
      bind :8888
      mode http
      monitor-uri /healthz
      option      dontlognull


    frontend stats
      bind *:8404
      stats enable
      stats uri /stats
      stats refresh 10s
      stats admin if LOCALHOST

    {{- $root := . }}
    {{- $fullName :=  include "arangodb.dbserver.fullname" . }}
    {{- $namespace := .Release.Namespace }}
    {{- $replicas := int (toString .Values.dbserver.replicas) }}
    # decide dbserver backend to use
    frontend ft_dbserver_leader
      bind *:8529 alpn h2,http/1.1
      use_backend bk_dbserver_leader

    backend bk_dbserver_leader
      option httpchk
      http-check send meth GET uri /_admin/server/availability
      http-check expect status 200
      default-server check resolvers dnsserver check fall 2 rise 1
      {{- range $i := until $replicas }}
      server DB{{ $i }} {{ $fullName }}-{{ $i }}.{{ $fullName }}-internal.{{ $namespace }}.svc.cluster.local:8529
      {{- end }}
{{- end }}

{{- define "config-haproxy_init.sh" }}
    HAPROXY_CONF=/data/haproxy.cfg
    cp /readonly/haproxy.cfg "$HAPROXY_CONF"
{{- end }}
