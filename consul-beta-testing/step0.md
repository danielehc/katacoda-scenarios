log Download App 0.14.1

```
curl -s https://github.com/nicholasjackson/fake-service/releases/download/v0.14.1/fake-service-linux
```

## Install GO 1.5.1

```
curl -s https://golang.org/dl/go1.15.1.linux-amd64.tar.gz
```

```
tar -C /usr/local -xzf go1.14.3.linux-amd64.tar.gz
```

```
echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile
```

## Build Consul locally

```
git clone git@github.com:hashicorp/consul.git
```

```
cd consul
```

curl -s https://github.com/hashicorp/consul/archive/envoy-lb-v2.zip

```
git checkout envoy-lb-v2
```

```
make dev
```