{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'sql-pvc',
  },
  spec: {    
    resources: {
      requests: {
        storage: '8Gi',
      },
    },
    volumeMode: 'Filesystem',
    accessModes: [
      'ReadWriteOnce',
    ],
  },
}
