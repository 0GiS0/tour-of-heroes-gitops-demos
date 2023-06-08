# Variables
RESOURCE_GROUP=flux-aks-tour-of-heroes
AKS_CLUSTER_NAME=flux-aks-tour-of-heroes


# Register providers
az provider register --namespace Microsoft.Kubernetes
az provider register --namespace Microsoft.KubernetesConfiguration
# AKS
az feature register --namespace Microsoft.ContainerService --name AKS-ExtensionManager
az provider register --namespace Microsoft.ContainerService
#Check status
az provider show -n Microsoft.Kubernetes --query "registrationState"
az provider show -n Microsoft.ContainerService --query "registrationState"
az provider show -n Microsoft.KubernetesConfiguration --query "registrationState"

# Get AKS credentials
az aks get-credentials -n $AKS_CLUSTER_NAME -g $RESOURCE_GROUP

# Enable CLI extensions
az extension add --name k8s-configuration
az extension add --name k8s-extension

# Generate a Flux Configuration
az k8s-configuration flux create \
--resource-group $RESOURCE_GROUP \
--cluster-name $AKS_CLUSTER_NAME \
--name wordpress-demo \
--namespace flux-system \
--cluster-type managedClusters \
--scope cluster \
-u https://github.com/0GiS0/kustomize-demo \
--branch main \
--kustomization name=prod-env path=prod prune=true

kubectl get all -n prod

# Generate a Flux Configuration
az k8s-configuration flux create \
--resource-group $RESOURCE_GROUP \
--cluster-name $AKS_CLUSTER_NAME \
--name tour-of-heroes \
--namespace flux-system \
--cluster-type managedClusters \
--scope cluster \
-u https://github.com/0GiS0/tour-of-heroes-gitops-demos \
--branch main \
--kustomization name=prod-env path=kustomize/overlays/production prune=true

kubectl get all -n tour-of-heroes

# https://learn.microsoft.com/es-es/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2?tabs=azure-cli
# https://learn.microsoft.com/es-es/azure/templates/microsoft.kubernetesconfiguration/fluxconfigurations?pivots=deployment-language-terraform
