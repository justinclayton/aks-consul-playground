KUBECTL := kubectl --kubeconfig azurek8s.kubeconfig
HELM := helm --kubeconfig azurek8s.kubeconfig

OLD_VERSION := v1.20.15
NEW_VERSION := v1.21.9

all: aks consul test

aks: terraform-apply azurek8s.kubeconfig

terraform-apply:
	terraform init
	terraform apply

azurek8s.kubeconfig:
	terraform output kube_config | grep -v EOT > azurek8s.kubeconfig
	chmod 600 azurek8s.kubeconfig

test: azurek8s.kubeconfig
	$(KUBECTL) get nodes
	$(HELM) ls
	$(KUBECTL) get pods --all-namespaces -o wide
	## to test consul after install, run:
	## > $(KUBECTL) port-forward service/consul-server --namespace consul 8500:8500 &
	## > open http://localhost:8500

consul: helm-install

helm-install:
	$(HELM) repo add hashicorp https://helm.releases.hashicorp.com
	$(HELM) search repo hashicorp/consul
	$(HELM) install consul hashicorp/consul --create-namespace --namespace consul --values config.yaml

## running this after editing the nodeSelector section, we see that the pod template of the statefulset will change, resulting in a restart.
## setting updatePartition to anything above 0 will utilize the RollingUpdate updateStrategy on the statefulset
helm-diff-upgrade:
	$(HELM) diff upgrade consul hashicorp/consul --namespace consul --values config.yaml

helm-upgrade:
	$(HELM) upgrade consul hashicorp/consul --namespace consul --values config.yaml

## add version labels
label-nodes: label-old-nodes label-new-nodes

label-old-nodes:
	$(KUBECTL) get no -o json | jq -r '.items[] | select(.status.nodeInfo.kubeletVersion == "$(OLD_VERSION)") | .metadata.labels."kubernetes.io/hostname"' \
	| xargs -I{} $(KUBECTL) label node {} aksVersion=$(OLD_VERSION)

label-new-nodes:
	$(KUBECTL) get no -o json | jq -r '.items[] | select(.status.nodeInfo.kubeletVersion == "$(NEW_VERSION)") | .metadata.labels."kubernetes.io/hostname"' \
	 | xargs -I{} $(KUBECTL) label node {} aksVersion=$(NEW_VERSION)

consul-test:
	$(KUBECTL) get pod -n consul -l app=consul -l component=server; echo
	$(KUBECTL) get pod -n consul -l app=consul -l component=server -o custom-columns='NAME:metadata.name,STATUS:status.phase,NODE:spec.nodeName,NODESELECTOR VALUE:spec.nodeSelector.aksVersion'; echo
	$(KUBECTL) exec --stdin --tty consul-server-1 --namespace consul -- consul operator raft list-peers; echo
# $(KUBECTL) get statefulset consul-server -n consul -o wide; echo
# $(KUBECTL) exec --stdin --tty consul-server-0 --namespace consul -- consul members

clean:
	terraform destroy
	rm -f azurek8s.kubeconfig
