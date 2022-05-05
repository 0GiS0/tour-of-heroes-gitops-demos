######################################################
################### Kustomize Demos ##################
######################################################

# Cambiar una imagen
cd kustomize/overlays/development
kustomize edit set image ghcr.io/0gis0/tour-of-heroes-dotnet-api/tour-of-heroes-api:75bd59f
