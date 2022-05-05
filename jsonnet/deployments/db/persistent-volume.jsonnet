{
  apiVersion: 'v1',
  kind: 'PersistentVolumeClaim',
  metadata: {
    name: 'azure-managed-csi-claim',
  },
  spec: {
    storageClassName: 'managed-csi',
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