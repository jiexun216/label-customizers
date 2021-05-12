# Makefile for building the Admission Controller webhook demo server + docker image.

.DEFAULT_GOAL := docker-build

# Image URL to use all building/pushing image targets
# IMG ?= admission:latest
IMAGE ?= daocloud.io/daocloud/cdp-securitycontext:latest
# deploy in which namespace
NAMESPACE ?= jiexun-test

image/webhook-server: $(shell find . -name '*.go')
	CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o cdp-securitycontext

# Build the docker image
.PHONY: docker-build
docker-build: image/webhook-server
	docker build --no-cache -t $(IMAGE) .
    rm -rf cdp-securitycontext

# Push the docker image
.PHONY: docker-push
docker-push: docker-build
	docker push $(IMAGE)

# Deploy admission webhook server
deploy:
	./deployment/webhook-create-signed-cert.sh  --namespace $(NAMESPACE)
	kubectl  create -f  ./deployment/rbac.yaml
	kubectl create -f deployment/service.yaml -n  $(NAMESPACE)
	kubectl create -f deployment/deployment.yaml -n $(NAMESPACE)
	cat ./deployment/mutatingwebhook.yaml | ./deployment/webhook-patch-ca-bundle.sh > ./deployment/mutatingwebhook-ca-bundle.yaml
	kubectl create -f deployment/mutatingwebhook-ca-bundle.yaml

# undeploy admission webhook server
undeploy:
    kubectl delete secret cdp-securitycontext-certs -n $(NAMESPACE)
    kubectl delete -f ./deployment/rbac.yaml
    kubectl delete -f deployment/service.yaml -n  $(NAMESPACE)
    kubectl delete -f deployment/deployment.yaml -n $(NAMESPACE)
    kubectl delete -f deployment/mutatingwebhook-ca-bundle.yaml