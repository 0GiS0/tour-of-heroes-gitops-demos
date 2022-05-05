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

# Comprobar cuántas kustomizaciones tenemos en el cluster configuradas
flux get kustomizations 

# Ver si ha creado el namespace
kubectl get ns

# Ver si ha creado los recursos dentro de dev-tour-of-heroes
kubectl get all -n dev-tour-of-heroes

######################################################
################### Helm Demos #######################
######################################################

# Instalar helm
brew install helm

# Crear un chart con helm
helm create demo-chart

# Instalar el chart de tour-of-heroes
helm install tour-of-heroes ./helm/tour-of-heroes-chart

# Comprobar los charts instalados
helm list

# Comprobar que la aplicación se ha desplegado
kubectl get all

# Desinstalar el chart de tour-of-heroes
helm delete tour-of-heroes

# Instalar el chart de tour-of-heroes con otros parámetros
helm install tour-of-heroes ./helm/tour-of-heroes-chart --set replicaCount=5 

# Comprobar que la aplicación se ha desplegado
kubectl get all

# Desinstalar el chart de tour-of-heroes
helm delete tour-of-heroes

# Instalar el chart de tour-of-heroes con otros parámetros en dev-values.yaml
helm install tour-of-heroes ./helm/tour-of-heroes-chart --values ./helm/dev-values.yaml

# Comprobar que la aplicación se ha desplegado
kubectl get all

# Actualizar chart de Helm con otros parámetros
helm upgrade tour-of-heroes ./helm/tour-of-heroes-chart --set replicaCount=2

# Comprobar que la aplicación se ha desplegado
kubectl get all

# Desinstalar el chart de tour-of-heroes
helm delete tour-of-heroes

#### Desplegar en ArgoCD
# Cambiamos el contexto de Kubernetes al cluster de argocd
kubectl config use-context kind-argocd

# Desplegamos la aplicación de Helm en Argo CD
argocd app create helm-tour-of-heroes \
--repo $REPO_URL \
--path helm/tour-of-heroes-chart \
--dest-namespace helm-tour-of-heroes \
--dest-server https://kubernetes.default.svc \
--sync-policy auto \
--sync-option "CreateNamespace=true" \
--upsert

### Desplegar en Flux CD
# Cambiamos de contexto de Kubernetes al cluster de fluxcd
kubectl config use-context kind-flux

# Crear aplicación con Helm en Flux CD
k create ns tour-of-heroes-helm

flux create helmrelease tour-of-heroes-helm \
--source=GitRepository/tour-of-heroes \
--chart="./helm/tour-of-heroes-chart" \
--target-namespace=tour-of-heroes-helm \
--interval=30s 

# Comprobar que el namespace existe
kubectl get ns 

# y que la aplicación está correctamente desplegada en él
kubectl get all -n tour-of-heroes-helm

######################################################
################### Jsonnet Demos ####################
######################################################

# Instalar jsonnet
brew install go-jsonnet

# Ver el resultado de un archivo jsonnet
jsonnet jsonnet/deployments/backend/deployment.jsonnet

# Usar jsonnet con funciones
jsonnet --tla-code "conf={image: 'HOLA LEMONCODERS!'}" jsonnet/jsonnet/deployment-with-a-function.jsonnet


# Cambiamos el contexto de Kubernetes al cluster de argocd
kubectl config use-context kind-argocd

# Crear la aplicación con jsonnet
argocd app create jsonnet-tour-of-heroes \
--repo $REPO_URL \
--path jsonnet/deployments \
--directory-recurse \
--dest-namespace tour-of-heroes-jsonnet \
--dest-server https://kubernetes.default.svc \
--sync-policy auto \
--sync-option "CreateNamespace=true" \
--upsert

######################################################
################### CI Integration ###################
######################################################

# Manifiestos planos
# Usando patch
kubectl patch --local -f plain-manifests/backend/deployment.yaml \
-p '{"spec":{"template":{"spec":{"containers":[{"name":"tour-of-heroes-api","image":"lemoncode.azurecr.io/tourofheroesapi:1234"}]}}}}' \
-o yaml > temp.yaml 


#### Kustomize

# Cambiar una imagen
cd kustomize/overlays/development
kustomize edit set image ghcr.io/0gis0/tour-of-heroes-dotnet-api/tour-of-heroes-api:1234

### Jsonnet
# Cambiar una imagen
jsonnet --tla-code "conf={image: 'HOLA LEMONCODERS!'}" jsonnet/jsonnet/deployment-with-a-function.jsonnet > temp.jsonnet

### Helm?

##### ArgoCD image updater #########

# Instalar Argo CD Image Updater
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/stable/manifests/install.yaml
# Important: It is not advised to run multiple replicas of the same Argo CD Image Updater instance. Just leave the number of replicas at 1, otherwise weird side effects could occur.

# Crear una aplicación con Argo CD Image Updater configurado para actualizar las imágenes automáticamente
argocd app create tour-of-heroes-image-updater \
--repo $REPO_URL \
--path helm/tour-of-heroes-chart \
--dest-namespace tour-of-heroes-helm \
--dest-server https://kubernetes.default.svc \
--sync-policy auto \
--sync-option "CreateNamespace=true" \
--annotations "argocd-image-updater.argoproj.io/image-list=api=ghcr.io/0gis0/tour-of-heroes-dotnet-api/tour-of-heroes-api, web=ghcr.io/0gis0/tour-of-heroes/tour-of-heroes" \
--annotations "argocd-image-updater.argoproj.io/api.helm.image-name=api.image.repository" \
--annotations "argocd-image-updater.argoproj.io/api.helm.image-tag=api.image.tag" \
--annotations "argocd-image-updater.argoproj.io/api.update-strategy=latest" \
--annotations "argocd-image-updater.argoproj.io/web.helm.image-name=image.repository" \
--annotations "argocd-image-updater.argoproj.io/web.helm.image-tag=image.tag" \
--annotations "argocd-image-updater.argoproj.io/web.update-strategy=latest" \
--upsert

# Comprobar los logs de Argo CD image updater
kubectl logs -n argocd -f $(kubectl get pod -l app.kubernetes.io/name=argocd-image-updater -n argocd -o name)


######################################################
################# Secretos seguros ###################
######################################################

# Decodificar un secreto en base64
echo U2VydmVyPXRvdXItb2YtaGVyb2VzLXNxbCwxNDMzO0luaXRpYWwgQ2F0YWxvZz1oZXJvZXM7UGVyc2lzdCBTZWN1cml0eSBJbmZvPUZhbHNlO1VzZXIgSUQ9c2E7UGFzc3dvcmQ9WW91clN0cm9uZyFQYXNzdzByZDsK | base64 -d

### Mozilla SOPS: https://fluxcd.io/docs/guides/mozilla-sops/

# Cambiamos el contexto de Kubernetes al cluster de flux
kubectl config use-context kind-flux

# Instalamos gnupg and SOPS
brew install gnupg sops

# Generamos un par de claves para poder cifrar y descifrars
export KEY_NAME="cluster0.returngis.net"
export KEY_COMMENT="flux secrets"

# Eliminar si tenemos una clave anterior con el mismo nombre
gpg --delete-secret-and-public-key $KEY_NAME

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

# Recuperamos el fingerprint de la clave
KEY=$(gpg --list-keys ${KEY_NAME} | grep pub -A 1 | grep -v pub)

# Crea un nuevo namespace para esta demo
kubectl create namespace tour-of-heroes-secrets

# Exporta el par de claves públicas y privadas de tu llavero GPG local
# y crear un secreto Kubernetes llamado sops-gpg en el namespace tour-of-heroes:
gpg --export-secret-keys --armor "${KEY_NAME}" |
kubectl create secret generic sops-gpg \
--namespace=tour-of-heroes-secrets \
--from-file=sops.asc=/dev/stdin

# Comprobamos que el secreto se ha creado correctamente
kubectl get secrets -n tour-of-heroes-secrets

# Crear un secreto para el backend

cat > ./secured-secrets/base/backend/secret.yaml <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: sqlserver-connection-string
type: Opaque
stringData:  
  password: Server=prod-tour-of-heroes-sql,1433;Initial Catalog=heroes;Persist Security Info=False;User ID=sa;Password=YourStrong!Passw0rd;
EOF

# Crear un secreto para la base de datos
cat > ./secured-secrets/base/db/secret.yaml <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: mssql
type: Opaque
stringData:  
  SA_PASSWORD: YourStrong!Passw0rd
EOF

#Crear configuración para SOPS
cat <<EOF > .sops.yaml
creation_rules:
  - path_regex: .*.yaml
    encrypted_regex: ^(data|stringData)$
    pgp: ${KEY}
EOF

# Cifrar el secreto para el backend
sops --encrypt ./secured-secrets/base/backend/secret.yaml > ./secured-secrets/base/backend/secret.enc.yaml

# Cifro el secreto para la base de datos
sops --encrypt ./secured-secrets/base/db/secret.yaml > ./secured-secrets/base/db/secret.enc.yaml

# Elimino el secreto que no está cifrado del backend
rm ./secured-secrets/base/backend/secret.yaml

# Elimino el secreto que no está cifrado de la base de datos
rm ./secured-secrets/base/db/secret.yaml

# IMPORTANTE: tienes que añadir estos archivos a los archivos kustomization.yaml

# Hago commit de estos cambios
git add -A && git commit -m "Demo secretos seguros"
git push

# Prueba de descifrado
sops --decrypt ./secured-secrets/base/backend/secret.enc.yaml > backend-secret.yaml

# Creo una source en con el repositorio en el mismo namespace que el secreto
flux create source git tour-of-heroes \
--namespace=tour-of-heroes-secrets \
--url=$REPO_URL \
--branch=main \
--interval=30s 

# Crear una aplicación en Flux con secretos cifrados en SOPS 
flux create kustomization tour-of-heroes-secured-secrets \
--source=tour-of-heroes \
--namespace=tour-of-heroes-secrets \
--path="secured-secrets/overlays/production" \
--prune=true \
--interval=10s \
--decryption-provider=sops \
--decryption-secret=sops-gpg 

# Comprobar que se ha aplicado el cambio
flux get kustomizations -n tour-of-heroes-secrets --watch

# Comprobar que la aplicación se ha desplegado correctamente
kubectl get pods -n tour-of-heroes-secrets

# Comprobar que los secretos se han creado correctamente
kubectl get secrets -n tour-of-heroes-secrets

# Ver el contenido de los secretos
kubectl get secret prod-mssql -n tour-of-heroes-secrets  -o jsonpath="{.data.SA_PASSWORD}" | base64 --decode

##################################################
########## Eliminar clusters en kind #############
##################################################
kind delete cluster --name flux
kind delete cluster --name argocd