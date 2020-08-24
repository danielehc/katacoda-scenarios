{{ with secret "pki_int/issue/consul-cluster" "common_name=server.dc1.nomad" "ttl=24h" "alt_names=localhost" "ip_sans=127.0.0.1"}}
{{ .Data.certificate }}
{{ end }}
