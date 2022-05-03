[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      labels: {
        app: 'tour-of-heroes-api',
      },
      name: 'tour-of-heroes-api',
    },
    spec: {
      type: 'LoadBalancer',
      ports: [
        {
          name: 'web',
          port: 80,
          targetPort: 5000,
        },
      ],
      selector: {
        app: 'tour-of-heroes-api',
      },
    },
  },
]
