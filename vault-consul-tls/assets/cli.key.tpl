{{ with secret "pki_int/issue/consul-datacenter" "ttl=24h" }}
{{ .Data.private_key }}
{{ end }}