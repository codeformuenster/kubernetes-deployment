
https://github.com/coreos/kube-prometheus#customizing-kube-prometheus


sudo docker run -v $PWD:/go/bin golang:1.12 \
    sh -c "go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb"
sudo mv ./jb /usr/local/bin/

sudo docker run -v $PWD:/go/bin golang:1.12 \
    sh -c "go get github.com/brancz/gojsontoyaml"
sudo mv ./gojsontoyaml /usr/local/bin/

# or run via docker
https://github.com/coreos/kube-prometheus#containerized-installing-and-compiling


jb init
jb install github.com/coreos/kube-prometheus/jsonnet/kube-prometheus@release-0.1


rm -r ../../manifests/kube-prometheus ; mkdir -p ../../manifests/kube-prometheus

jsonnet -J ./jsonnet/vendor -m ../../manifests/kube-prometheus base.jsonnet \
    | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml; rm -f {}' -- {}


kubectl apply -f ../../manifests/kube-prometheus
kubectl apply -f ./grafana-Ingress.yaml
