

docker exec server consul config write /etc/consul.d/config-intentions-api.hcl
Config entry written: service-intentions/api


docker exec server consul intention match "api"
web => api (allow)
* => * (deny)

docker exec server consul config write /etc/consul.d/config-intentions-web.hcl
Config entry written: service-intentions/web

docker exec server consul intention match "web"
ingress-service => web (1 permission)
* => * (deny)

curl --silent  localhost:8500/v1/connect/intentions | jq
[
  {
    "SourceNS": "default",
    "SourceName": "ingress-service",
    "DestinationNS": "default",
    "DestinationName": "web",
    "SourceType": "consul",
    "Permissions": [
      {
        "Action": "allow",
        "HTTP": {
          "PathExact": "/ui",
          "Methods": [
            "GET"
          ]
        }
      }
    ],
    "Precedence": 9,
    "CreateIndex": 128,
    "ModifyIndex": 128
  },
  {
    "SourceNS": "default",
    "SourceName": "web",
    "DestinationNS": "default",
    "DestinationName": "api",
    "SourceType": "consul",
    "Action": "allow",
    "Precedence": 9,
    "CreateIndex": 97,
    "ModifyIndex": 97
  },
  {
    "SourceNS": "default",
    "SourceName": "*",
    "DestinationNS": "default",
    "DestinationName": "*",
    "SourceType": "consul",
    "Action": "deny",
    "Precedence": 5,
    "CreateIndex": 69,
    "ModifyIndex": 69
  }
]