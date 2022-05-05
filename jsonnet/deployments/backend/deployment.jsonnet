{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    labels: {
      app: 'tour-of-heroes-api',
    },
    name: 'tour-of-heroes-api',
  },
  spec: {
    replicas: 1,
    revisionHistoryLimit: 1,
    selector: {
      matchLabels: {
        app: 'tour-of-heroes-api',
      },
    },
    template: {
      metadata: {
        labels: {
          app: 'tour-of-heroes-api',
        },
      },
      spec: {
        containers: [
          {
            env: [
              {
                name: 'ConnectionStrings__DefaultConnection',
                valueFrom: {
                  secretKeyRef: {
                    key: 'password',
                    name: 'sqlserver-connection-string',
                  },
                },
              },
            ],
            image: 'ghcr.io/0gis0/tour-of-heroes-dotnet-api/tour-of-heroes-api:75bd59f',
            name: 'tour-of-heroes-api',
            ports: [
              {
                containerPort: 5000,
                name: 'web',
              },
            ],
          },
        ],
      },
    },
  },
}
