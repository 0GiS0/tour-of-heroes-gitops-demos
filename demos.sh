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

# Crear la aplicación con la configuración de producción de Kustomize
argocd app create kustomize-tour-of-heroes-prod \
--repo $REPO_URL \
--path kustomize/overlays/production \
--dest-server https://kubernetes.default.svc \
--sync-policy auto \
--sync-option "CreateNamespace=true" \
--upsert

### Despliegue en Flux cd

# Cambiamos de contexto de Kubernetes al cluster de fluxcd
kubectl config use-context kind-flux

### Kustomize

# Comprobar las fuentes ya dadas de alta
flux get sources git --all-namespaces

# Dar de alta el repo en Flux
flux create source git tour-of-heroes \
--url=$REPO_URL \
--branch=main \
--interval=30s 

# Crear la aplicación con la configuración de desarrollo de Kustomize
flux create kustomization tour-of-heroes-kustomize \
--source=tour-of-heroes \
--path="./kustomize/overlays/development" \
--prune=true \
--interval=30s 

flux get kustomizations 

# Ver si ha creado el namespace
kubectl get ns

# Ver si ha creado los recursos dentro de dev-tour-of-heroes
kubectl get all -n dev-tour-of-heroes

flux get all 

######################################################
################### Helm Demos #######################
######################################################


######################################################
################### Jsonnet Demos ####################
######################################################

# Add repo with jsonnet files
REPO_URL="https://gis@dev.azure.com/gis/Tour%20Of%20Heroes%20GitOps/_git/Tour%20Of%20Heroes%20Jsonnet"
USER_NAME="giselatb"
PASSWORD="poflpbieyctfiuwr2zkbpgxum7ifavpgp3eqqcwmmrpfouao7xaq"

argocd repo add $REPO_URL \
--name tour-of-heroes-jsonnet \
--type git \
--username $USER_NAME \
--password $PASSWORD \
--project tour-of-heroes

# Create app with jsonnet repo
argocd app create jsonnet-tour-of-heroes \
--repo $REPO_URL \
--path deployments \
--directory-recurse \
--dest-namespace tour-of-heroes-jsonnet \
--dest-server https://kubernetes.default.svc \
--sync-policy auto \
--sync-option "CreateNamespace=true" \
--upsert

######################################################
################### CI Integration ###################
######################################################

#### Kustomize

# Cambiar una imagen
cd kustomize/overlays/development
kustomize edit set image ghcr.io/0gis0/tour-of-heroes-dotnet-api/tour-of-heroes-api:75bd59f


##### ArgoCD image updater #########

# Install Argo CD Image Updater
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
# Important: It is not advised to run multiple replicas of the same Argo CD Image Updater instance. Just leave the number of replicas at 1, otherwise weird side effects could occur.

# Modify argocd-image-updater-config
export KUBE_EDITOR="code --wait"

# k edit cm -n argocd argocd-image-updater-config

# Create a service principal 
SERVICE_PRINCIPAL_NAME=argocd-acr-sp

# Obtain the full registry ID for subsequent command args
ACR_REGISTRY_ID=$(az acr show --name $ACR_NAME --query "id" --output tsv)

# Create the service principal with rights scoped to the registry.
# Default permissions are for docker pull access. Modify the '--role'
# argument value as desired:
# acrpull:     pull only
# acrpush:     push and pull
# owner:       push, pull, and assign roles
PASSWORD=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME --scopes $ACR_REGISTRY_ID --role acrpull --query "password" --output tsv)
USER_NAME=$(az ad sp list --display-name $SERVICE_PRINCIPAL_NAME --query "[].appId" --output tsv)

# Create a secret with the ACR credentials
kubectl create secret docker-registry acr-credentials \
    --namespace argocd \
    --docker-server=$ACR_NAME.azurecr.io \
    --docker-username=$USER_NAME \
    --docker-password=$PASSWORD

# Add repo with Helm chart
REPO_URL="https://gis@dev.azure.com/gis/Tour%20Of%20Heroes%20GitOps/_git/Tour%20Of%20Heroes%20GitOps%20with%20Helm"
USER_NAME="giselatb"
PASSWORD="gg4vlktdlqel5tf7hi4aygwznu2nked52krhuwksefjmjsxyd5sq"

argocd repo add $REPO_URL \
--name tour-of-heroes-gitops-with-helm \
--type git \
--username $USER_NAME \
--password $PASSWORD \
--project tour-of-heroes

# Create an application with the Argo CD Image Updater
argocd app create tour-of-heroes-helm \
--repo $REPO_URL \
--path tour-of-heroes-chart \
--dest-namespace tour-of-heroes-helm \
--dest-server https://kubernetes.default.svc \
--sync-policy auto \
--sync-option "CreateNamespace=true" \
--annotations "argocd-image-updater.argoproj.io/image-list=api=$ACR_NAME.azurecr.io/tourofheroesapi, web=$ACR_NAME.azurecr.io/tourofheroesweb" \
--annotations "argocd-image-updater.argoproj.io/api.helm.image-name=api.image.repository" \
--annotations "argocd-image-updater.argoproj.io/api.helm.image-tag=api.image.tag" \
--annotations "argocd-image-updater.argoproj.io/api.pull-secret=pullsecret:argocd/acr-credentials" \
--annotations "argocd-image-updater.argoproj.io/api.update-strategy=latest" \
--annotations "argocd-image-updater.argoproj.io/web.helm.image-name=image.repository" \
--annotations "argocd-image-updater.argoproj.io/web.helm.image-tag=image.tag" \
--annotations "argocd-image-updater.argoproj.io/web.pull-secret=pullsecret:argocd/acr-credentials" \
--annotations "argocd-image-updater.argoproj.io/web.update-strategy=latest" \
--upsert

# Check argocd image updater logs
kubectl logs -n argocd -f argocd-image-updater-59c45cbc5c-pktkn

# Create an application with the Argo CD Image Updater for branch dev
argocd app create tour-of-heroes-helm-dev \
--repo $REPO_URL \
--path tour-of-heroes-chart \
--revision dev \
--dest-namespace tour-of-heroes-helm \
--dest-server https://kubernetes.default.svc \
--sync-policy auto \
--sync-option "CreateNamespace=true" \
--annotations "argocd-image-updater.argoproj.io/image-list=api=$ACR_NAME.azurecr.io/tourofheroesapi, web=$ACR_NAME.azurecr.io/tourofheroesweb" \
--annotations "argocd-image-updater.argoproj.io/api.helm.image-name=api.image.repository" \
--annotations "argocd-image-updater.argoproj.io/api.helm.image-tag=api.image.tag" \
--annotations "argocd-image-updater.argoproj.io/api.pull-secret=pullsecret:argocd/acr-credentials" \
--annotations "argocd-image-updater.argoproj.io/api.update-strategy=latest" \
--annotations "argocd-image-updater.argoproj.io/web.helm.image-name=image.repository" \
--annotations "argocd-image-updater.argoproj.io/web.helm.image-tag=image.tag" \
--annotations "argocd-image-updater.argoproj.io/web.pull-secret=pullsecret:argocd/acr-credentials" \
--annotations "argocd-image-updater.argoproj.io/web.update-strategy=latest" \
--upsert






######################################################
################# Secretos seguros ###################
######################################################

### Mozilla SOPS: https://fluxcd.io/docs/guides/mozilla-sops/

# Install gnupg and SOPS
brew install gnupg sops

# Generate a GPG key
export KEY_NAME="cluster0.returngis.net"
export KEY_COMMENT="flux secrets"

gpg --batch --full-generate-key <<EOF
%no-protection
Key-Type: 1
Key-Length: 4096
Subkey-Type: 1
Subkey-Length: 4096
Expire-Date: 0
Name-Comment: ${KEY_COMMENT}
Name-Real: ${KEY_NAME}
EOF

# Retrieve the GPG key fingerprint
KEY=$(gpg --list-keys ${KEY_NAME} | grep pub -A 1 | grep -v pub)

# Export the public and private keypair from your local GPG keyring
# and create a Kubernetes secret named sops-gpg in the tour-of-heroes namespace:
gpg --export-secret-keys --armor "${KEY_NAME}" |
kubectl create secret generic sops-gpg \
--namespace=tour-of-heroes \
--from-file=sops.asc=/dev/stdin

kubectl get secrets -n tour-of-heroes

# Create secrets for backend and db
# Create a secret for the backend

cat > ./tour-of-heroes-secured-secrets/base/backend/secret.yaml <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: sqlserver-connection-string
type: Opaque
stringData:  
  password: Server=prod-tour-of-heroes-sql,1433;Initial Catalog=heroes;Persist Security Info=False;User ID=sa;Password=YourStrong!Passw0rd;
EOF

# Create a secret for the db
cat > ./tour-of-heroes-secured-secrets/base/db/secret.yaml <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: mssql
type: Opaque
stringData:  
  SA_PASSWORD: YourStrong!Passw0rd
EOF

#Create SOPS configuration
cat <<EOF > .sops.yaml
creation_rules:
  - path_regex: .*.yaml
    encrypted_regex: ^(data|stringData)$
    pgp: ${KEY}
EOF

# Encrypt secret for backend
sops --encrypt ./tour-of-heroes-secured-secrets/base/backend/secret.yaml > ./tour-of-heroes-secured-secrets/base/backend/secret.enc.yaml
# Remove the unencrypted secret
rm ./tour-of-heroes-secured-secrets/base/backend/secret.yaml

# Encrypt secret for db
sops --encrypt ./tour-of-heroes-secured-secrets/base/db/secret.yaml > ./tour-of-heroes-secured-secrets/base/db/secret.enc.yaml
# Remove the unencrypted secret
rm ./tour-of-heroes-secured-secrets/base/db/secret.yaml

# IMPORTANT: you have to add this files to the kustomization.yaml files

# Add this changes to the repo
git add -A && git commit -m "Add secured secret demo"
git push

# Test decryption
sops --decrypt ./tour-of-heroes-secured-secrets/base/backend/secret.enc.yaml > backend-secret.yaml

# Create a source of this repo
flux create source git tour-of-heroes-secured-secrets \
--namespace=tour-of-heroes \
--url=$REPO_GITOPS_DEMOS \
--branch=main \
--interval=30s \
--export > ./clusters/$CLUSTER_NAME/sources/tour-of-heroes-secured-secrets.yaml

# Create an application in Flux with SOPS 
flux create kustomization tour-of-heroes-secured-secrets \
--namespace=tour-of-heroes \
--source=tour-of-heroes-secured-secrets \
--path="secured-secrets/overlays/production" \
--prune=true \
--interval=10s \
--decryption-provider=sops \
--decryption-secret=sops-gpg \
--export > ./clusters/$CLUSTER_NAME/apps/tour-of-heroes-secured-secrets.yaml

# Add this changes to the repo
git add -A && git commit -m "Add tour-of-heroes-secured-secrets"
git push

# En el caso de los SOP secrets no añade el prod- por delante del secreto

# Check the deployment
flux get kustomizations -n tour-of-heroes --watch

# Check status in Grafana
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
http://localhost:3000/d/flux-cluster/flux-cluster-stats?orgId=1&refresh=10s

# See secret decoded
kubectl -n prod-tour-of-heroes get secrets

### Sealed Secrets: https://fluxcd.io/docs/guides/sealed-secrets/

# Install the kubeseal CLI
brew install kubeseal

# Add the source for sealed secrets
flux create source helm sealed-secrets \
--interval=1h \
--url=https://bitnami-labs.github.io/sealed-secrets \
--export > ./clusters/$AKS_NAME/sources/sealed-secrets.yaml

# Create a helm release for sealed secrets
flux create helmrelease sealed-secrets \
--interval=1h \
--release-name=sealed-secrets-controller \
--target-namespace=flux-system \
--source=HelmRepository/sealed-secrets \
--chart=sealed-secrets \
--chart-version=">=1.15.0-0" \
--crds=CreateReplace \
--export > ./clusters/$CLUSTER_NAME/apps/sealed-secrets.yaml

# Push changes
git add -A && git commit -m "Add sealed secrets demo"
git push

# check helm releases
flux get helmreleases -n flux-system --watch

# At startup, the sealed-secrets controller generates a 4096-bit RSA key pair and persists the private and public keys 
# as Kubernetes secrets in the flux-system namespace.
# You can retrieve the public key with:
kubeseal --fetch-cert \
--controller-name=sealed-secrets-controller \
--controller-namespace=flux-system \
> pub-sealed-secrets.pem

# Create secrets for backend and db
# Create a secret for the backend

cat > ./tour-of-heroes-secured-secrets/base/backend/secret.yaml <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: sqlserver-connection-string
type: Opaque
stringData:  
  password: Server=prod-tour-of-heroes-sql,1433;Initial Catalog=heroes;Persist Security Info=False;User ID=sa;Password=YourStrong!Passw0rd;
EOF

# Create a secret for the db
cat > ./tour-of-heroes-secured-secrets/base/db/secret.yaml <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: mssql
type: Opaque
stringData:  
  SA_PASSWORD: YourStrong!Passw0rd
EOF

# Encrypt the secrets with kubeseal
kubeseal --scope cluster-wide --format=yaml --cert=pub-sealed-secrets.pem \
< tour-of-heroes-secured-secrets/base/backend/secret.yaml > tour-of-heroes-secured-secrets/base/backend/secret-sealed.yaml

# Remove the unencrypted secret
rm tour-of-heroes-secured-secrets/base/backend/secret.yaml

kubeseal --scope cluster-wide --format=yaml --cert=pub-sealed-secrets.pem \
< tour-of-heroes-secured-secrets/base/db/secret.yaml > tour-of-heroes-secured-secrets/base/db/secret-sealed.yaml

# Remove the unencrypted secret
rm tour-of-heroes-secured-secrets/base/db/secret.yaml

# IMPORTANT: Update the kustomization.yaml files with the secret-sealed.yaml files

# Push changes
git add -A && git commit -m "Add secrets-seaed files"
git push

# Check the deployment
flux get kustomizations -n tour-of-heroes --watch

k get all -n prod-tour-of-heroes

# Check sealed secret controller
k logs sealed-secrets-controller-868754dd89-mfpvw -n flux-system -f

# En el caso de los sealed secrets si que añade el prod- por delante del secreto

https://medium.com/@udhanisuranga/how-to-manage-k8s-secrets-in-aks-clusters-using-secret-store-csi-drivers-and-azure-key-vaults-5ec590a9cf51

https://docs.microsoft.com/es-es/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2

##################################################
########## Eliminar clusters en kind #############
##################################################
kind delete cluster --name flux