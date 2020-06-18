

`export IP_ADDR=$(hostname -I | awk '{print $1}')`{{execute}}

`kubectl port-forward service/web 9090:9090 --address ${IP_ADDR}`{{execute}}