ingress "dashboard_dc1" {
    target = "k8s_cluster.dc1"
    service = "svc/kubernetes-dashboard"
    namespace = "kubernetes-dashboard"

    network  {
      name = "network.local"
    }

    port {
        remote = 8443
        local = 8443
        host = 18443
        open_in_browser = "/#/overview?namespace=default"
    }
}

ingress "dashboard_dc2" {
    target = "k8s_cluster.dc2"
    service = "svc/kubernetes-dashboard"
    namespace = "kubernetes-dashboard"

    network  {
      name = "network.local"
    }

    port {
        remote = 8443
        local = 8443
        host = 19443
        open_in_browser = "/#/overview?namespace=default"
    }
}

ingress "consul_dc1" {
    target = "k8s_cluster.dc1"
    service = "svc/consul-server"

    network  {
      name = "network.local"
    }

    port {
        remote = 8500
        local = 8500
        host = 18500
    }
}

ingress "consul_dc2" {
    target = "k8s_cluster.dc2"
    service = "svc/consul-server"

    network  {
      name = "network.local"
    }

    port {
        remote = 8500
        local = 8500
        host = 18600
    }
}