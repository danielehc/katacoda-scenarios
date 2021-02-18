## Change service definition

`docker exec \
  --env CONSUL_HTTP_ADDR='127.0.0.1:8500' \
  --env CONSUL_HTTP_TOKEN="${CONSUL_HTTP_TOKEN}" \
  api sh -c "consul services register /assets/svc-api-tag.hcl"`{{execute T1}}

  