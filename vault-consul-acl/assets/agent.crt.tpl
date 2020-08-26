{{ with secret "pki_int/issue/consul-dc1" "common_name=server.dc1.consul" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1"}}
{{ .Data.certificate }}
{{ end }}