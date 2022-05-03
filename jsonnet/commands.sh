# https://brian-candler.medium.com/streamlining-kubernetes-application-deployment-with-jsonnet-711e15e9c665
# https://medium.com/kapitan-blog/kubernetes-with-jsonnet-and-kapitan-5e3991d5bca
# https://tanka.dev/tutorial/jsonnet
# https://github.com/google/go-jsonnet
https://github.com/kapicorp/kapitan


# Install jsonnet tool
brew install go-jsonnet

# Test jsonnet
jsonnet -e "1+2"

# or you can put in a file
echo "1+2" > test.jsonnet
jsonnet test.jsonnet

# Online conversion tool
https://jsonnet.org/articles/kubernetes.html#syntax
# Use it with the plain-yamls folder in the repo

#It shows the jsonnet file in the terminal
jsonnet jsonnet/deployment.jsonnet

# So far so meh :-)

#Format jsonnet files
jsonnetfmt -i jsonnet/*.jsonnet
jsonnetfmt -i deployments/**/*.jsonnet


# See the result of deployment-with-parameters.jsonnet. It has parameters
jsonnet jsonnet/deployment-with-parameters.jsonnet

# See the result of deployment-with-a-function.jsonnet. It has a function
jsonnet --tla-code "conf={image: 'test'}" jsonnet/deployment-with-a-function.jsonnet
#tla stands for top level argument

# You can also put arguments in a separate file like conf.jsonnet
# and apply it
jsonnet --tla-code-file conf=jsonnet/conf.jsonnet jsonnet/deployment-with-a-function.jsonnet

# Create a jsonnet with the configuration that imports the function
jsonnet jsonnet/prod.jsonnet

# Add more resources on the fly
jsonnet jsonnet/prod-adjustments.jsonnet

# Change the name of the image via command in jsonnet
jsonnet --tla-code "conf={image: 'test'}" jsonnet/deployment-with-a-function.jsonnet

jsonnet --tla-code "conf={image: '$(ACR_NAME).azurecr.io/tourofheroesapi:$(Build.BuildId)'}" jsonnet/deployment-with-a-function.jsonnet > deployments/deployment.jsonnet 