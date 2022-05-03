[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      labels: {
        app: 'tour-of-heroes-sql',
      },
      name: 'tour-of-heroes-sql',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'tour-of-heroes-sql',
        },
      },
      template: {
        metadata: {
          labels: {
            app: 'tour-of-heroes-sql',
          },
        },
        spec: {
          terminationGracePeriodSeconds: 30,
          hostname: 'mssqlinst',
          securityContext: {
            fsGroup: 10001,
          },
          containers: [
            {
              image: 'mcr.microsoft.com/mssql/server:latest',
              name: 'sqlserver',
              ports: [
                {
                  containerPort: 1433,
                },
              ],
              volumeMounts: [
                {
                  mountPath: '/var/opt/mssql',
                  name: 'sqlserver-data',
                },
              ],
              env: [
                {
                  name: 'ACCEPT_EULA',
                  value: 'Y',
                },
                {
                  name: 'SA_PASSWORD',
                  valueFrom: {
                    secretKeyRef: {
                      name: 'mssql',
                      key: 'SA_PASSWORD',
                    },
                  },
                },
                {
                  name: 'MSSQL_PID',
                  value: 'Developer',
                },
              ],
            },
          ],
          volumes: [
            {
              name: 'sqlserver-data',
              persistentVolumeClaim: {
                claimName: 'azure-managed-csi-claim',
              },
            },
          ],
        },
      },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      labels: {
        app: 'tour-of-heroes-sql',
      },
      name: 'tour-of-heroes-sql',
    },
    spec: {
      ports: [
        {
          name: 'sqlserverport',
          port: 1433,
          targetPort: 1433,
        },
      ],
      selector: {
        app: 'tour-of-heroes-sql',
      },
    },
  },
]
