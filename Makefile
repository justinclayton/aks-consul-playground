all: aks consul test

aks: terraform-apply azurek8s.kubeconfig

terraform-apply:
	terraform init
	terraform apply

azurek8s.kubeconfig:
	terraform output kube_config | grep -v EOT > $@

test: azurek8s.kubeconfig
	kubectl --kubeconfig azurek8s.kubeconfig get nodes
	helm ls --kubeconfig azurek8s.kubeconfig
	kubectl --kubeconfig azurek8s.kubeconfig get pods --all-namespaces
	## to test consul after install, run:
	## > kubectl port-forward service/consul-server --namespace consul 8500:8500 &
	## > open http://localhost:8500

consul: install-consul

install-consul:
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm search repo hashicorp/consul
	helm install consul hashicorp/consul --create-namespace --namespace consul --values config.yaml --kubeconfig azurek8s.kubeconfig

upgrade-consul:
	helm upgrade consul hashicorp/consul --namespace consul --values config.yaml --kubeconfig azurek8s.kubeconfig

clean:
	terraform destroy
	rm -f azurek8s.kubeconfig
