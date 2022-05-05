[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      labels: {
        app: 'tour-of-heroes-web',
      },
      name: 'tour-of-heroes-web',
    },
    spec: {
      replicas: 5,
      revisionHistoryLimit: 1,
      selector: {
        matchLabels: {
          app: 'tour-of-heroes-web',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'tour-of-heroes-web',
          },
        },
        spec: {
          containers: [
            {
              env: [
                {
                  name: 'API_URL',
                  value: 'http://20.67.170.114/api/hero',
                },
              ],
              image: 'ghcr.io/0gis0/tour-of-heroes/tour-of-heroes:aadda92',
              name: 'tour-of-heroes-web',
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
  },
]
