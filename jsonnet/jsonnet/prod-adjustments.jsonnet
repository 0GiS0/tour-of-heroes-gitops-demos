local conf = {
    image: 'image_from_prod.jsonnet'
};

local deployment = import 'deployment-with-a-function.jsonnet';

deployment(conf){
    metadata+:{
        namespace: 'lemoncode'
    },
    spec+:{
        replicas: 20
    }
}