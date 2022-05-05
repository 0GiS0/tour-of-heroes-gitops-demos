[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      labels: {
        app: 'tour-of-heroes-web',
      },
      name: 'tour-of-heroes-web',
    },
    spec: {
      type: 'NodePort',
      ports: [
        {
          name: 'web',
          port: 80,
          targetPort: 80,
        },
      ],
      selector: {
        app: 'tour-of-heroes-web',
      },
    },
  },
]
