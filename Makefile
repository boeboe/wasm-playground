# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# Configurable parameters
CLUSTER_NAME            ?= wasm-playground
ISTIO_HELM_REPO_NAME    ?= tetratelabs
ISTIO_HELM_REPO_URL     ?= https://tetratelabs.github.io/helm-charts
ISTIO_INGRESS_NAMESPACE ?= istio-ingress
ISTIO_SYSTEM_NAMESPACE  ?= istio-system
ISTIO_VERSION           ?= 1.18.3
K8S_VERSION             ?= 1.27.3
METALLB_NAMESPACE       ?= metallb-system
METALLB_VERSION         ?= 0.13.12
METALLB_HELM_REPO_NAME  ?= metallb
METALLB_HELM_REPO_URL   ?= https://metallb.github.io/metallb

# Targets
.PHONY: create-cluster install-metallb install-istio 
.PHONY: uninstall-istio uninstall-metallb delete-cluster

up: create-cluster install-metallb install-istio ## Bring up local Kubernetes cluster with Istio
down: delete-cluster ## Bring down local Kubernetes cluster with Istio

create-cluster: ## Create local Kubernetes cluster
	@if kind get clusters | grep -q $(CLUSTER_NAME); then \
		echo "Kubernetes cluster $(CLUSTER_NAME) already exists"; \
	else \
		echo "Creating Kubernetes cluster..."; \
		kind create cluster --name $(CLUSTER_NAME) --image kindest/node:v$(K8S_VERSION); \
		kubectl cluster-info --context kind-$(CLUSTER_NAME); \
		echo "Waiting for specific pods to be running..."; \
		for pod in kube-apiserver-$(CLUSTER_NAME)-control-plane kube-scheduler-$(CLUSTER_NAME)-control-plane kube-controller-manager-$(CLUSTER_NAME)-control-plane; do \
			kubectl wait --for=condition=ready pod/$$pod --namespace=kube-system --timeout=300s --context kind-$(CLUSTER_NAME); \
		done; \
		echo "Kubernetes cluster $(CLUSTER_NAME) created successfully"; \
	fi
	@echo "To get pods in all namespaces: kubectl --context kind-$(CLUSTER_NAME) get pods -A"


install-metallb: ## Install MetalLB
	@echo "Installing or Upgrading MetalLB..."
	@helm repo add ${METALLB_HELM_REPO_NAME} ${METALLB_HELM_REPO_URL}
	@helm repo update
	@kubectl create namespace $(METALLB_NAMESPACE) || true
	$(eval IP_RANGE_START := $(shell docker container inspect wasm-playground-control-plane -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' | awk -F. '{$$4="100"; print $$1"."$$2"."$$3"."$$4}'))
	$(eval IP_RANGE_END := $(shell docker container inspect wasm-playground-control-plane -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' | awk -F. '{$$4="200"; print $$1"."$$2"."$$3"."$$4}'))
	@helm upgrade --install metallb ${METALLB_HELM_REPO_NAME}/metallb \
		--namespace ${METALLB_NAMESPACE} \
		--version v$(METALLB_VERSION) \
		--wait
	@echo "apiVersion: metallb.io/v1beta1\nkind: IPAddressPool\nmetadata:\n  namespace: $(METALLB_NAMESPACE)\n  name: default\nspec:\n  addresses:\n  - $(IP_RANGE_START)-$(IP_RANGE_END)\n" | kubectl apply -f -
	

uninstall-metallb: ## Uninstall MetalLB
	@echo "Uninstalling MetalLB..."
	@helm uninstall metallb --namespace ${METALLB_NAMESPACE} || true
	@kubectl --context kind-$(CLUSTER_NAME) delete namespace ${METALLB_NAMESPACE} || true
	@echo "MetalLB uninstalled successfully"


install-istio: ## Install or Upgrade Istio
	@echo "Installing or Upgrading Istio..."
	@helm repo add ${ISTIO_HELM_REPO_NAME} $(ISTIO_HELM_REPO_URL) || true
	@helm repo update

	@kubectl create namespace $(ISTIO_SYSTEM_NAMESPACE) || true
	@echo "Installing or upgrading Istio Base..."
	@helm upgrade --install istio-base ${ISTIO_HELM_REPO_NAME}/base -n $(ISTIO_SYSTEM_NAMESPACE) --version $(ISTIO_VERSION) --wait

	@echo "Installing or upgrading Istiod..."
	@helm upgrade --install istiod ${ISTIO_HELM_REPO_NAME}/istiod -n $(ISTIO_SYSTEM_NAMESPACE) --version $(ISTIO_VERSION) --wait

	@kubectl create namespace $(ISTIO_INGRESS_NAMESPACE) || true
	@echo "Installing or upgrading Istio Ingress..."
	@helm upgrade --install istio-ingress ${ISTIO_HELM_REPO_NAME}/gateway -n $(ISTIO_INGRESS_NAMESPACE) --version $(ISTIO_VERSION) --wait

	@kubectl --context kind-$(CLUSTER_NAME) label namespace default istio-injection=enabled --overwrite
	@echo "Istio installation or upgrade completed."
	@kubectl --context kind-$(CLUSTER_NAME) get services -A
	@echo "To get pods in all namespaces: kubectl --context kind-$(CLUSTER_NAME) get pods -A"


uninstall-istio: ## Uninstall Istio
	@echo "Uninstalling Istio..."
	@helm uninstall istio-ingress -n $(ISTIO_INGRESS_NAMESPACE) || true
	@kubectl --context kind-$(CLUSTER_NAME) delete namespace $(ISTIO_INGRESS_NAMESPACE) || true
	@helm uninstall istiod -n $(ISTIO_SYSTEM_NAMESPACE) || true
	@helm uninstall istio-base -n $(ISTIO_SYSTEM_NAMESPACE) || true
	@kubectl --context kind-$(CLUSTER_NAME) delete namespace $(ISTIO_SYSTEM_NAMESPACE) || true


delete-cluster: ## Delete local Kubernetes cluster
	@echo "Deleting Kubernetes cluster..."
	@kind delete cluster --name $(CLUSTER_NAME)

