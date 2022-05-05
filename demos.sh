######################################################
################### Kustomize Demos ##################
######################################################

# Ver la configuración para development
kubectl apply -k ./kustomize/overlays/development --dry-run -o yaml

# Ver la configuración para production
kubectl apply -k ./kustomize/overlays/production --dry-run -o yaml

### Desplegarlo en ArgoCD

# Instalamos el CLI de ArgoCD
brew install argocd

# Cambiamos el contexto de Kubernetes al cluster de argocd
kubectl config use-context kind-argocd

# Acceder a la interfaz de ArgoCD 
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Iniciar sesión en Argo CD
argocd login localhost:8080

# Crear la aplicación con la configuración de desarrollo con Kustomize

# Añadir el repositorio
REPO_URL="https://github.com/0GiS0/tour-of-heroes-gitops-demos"

argocd repo add $REPO_URL \
--name tour-of-heroes-kustomize \
--type git

# Crear la aplicación con la configuración de desarrollo de Kustomize
argocd app create kustomize-tour-of-heroes \
--repo $REPO_URL \
--path kustomize/overlays/development \
--dest-server https://kubernetes.default.svc \
--sync-policy auto \
--sync-option "CreateNamespace=true" \
--upsert


### Despliegue en flux cd

# Cambiamos de contexto de Kubernetes al cluster de fluxcd
kubectl config use-context kind-fluxcd

# Cambiar una imagen
cd kustomize/overlays/development
kustomize edit set image ghcr.io/0gis0/tour-of-heroes-dotnet-api/tour-of-heroes-api:75bd59f
