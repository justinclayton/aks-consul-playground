# aks-consul-playground

## prereqs

1. have a valid Azure subscription and be authenticated in your terminal, however you like to do that
1. add a `terraform.tfvars` file to add a value for the `subscription_id` variable, and to override anything else in the terraform that you like. it will be gitignored.

## install 

1. run `make aks` to build the resource group, AKS cluster and its node pools, etc.
1. run `make test` to validate your kubernetes connection to the new cluster via the newly created `azurek8s.kubeconfig`.
1. run `make consul` to install consul via helm. edit the helm values file `config.yaml` as desired ahead of doing the install.

or run `make all` or simply `make` to do it all at once.

## other things you can do

* edit the `config.yaml` and run `make upgrade-consul` to perform an in-place helm upgrade.
* destroy everything with `make clean`

## things to be aware of if you use this for your own purposes

* i'm using this to mess with version upgrades, so i'm defining `var.version_1` and `var.version_2` to be different kube versions and intentionally not creating the cluster with the newest version.