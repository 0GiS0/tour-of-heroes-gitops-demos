# Get AKS credentials
az aks get-credentials -n aks-tour-of-heroes -g aks-tour-of-heroes

### https://argo-cd.readthedocs.io/en/stable/getting_started/ ###

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Check ArgoCD installation
watch kubectl get pods -n argocd

# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access ArgoCD portal
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Download Argo CLI
brew install argocd