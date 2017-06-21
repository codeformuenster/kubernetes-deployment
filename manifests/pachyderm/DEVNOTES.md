http://pachyderm.readthedocs.io/en/stable/deployment/on_premises.html

https://github.com/pachyderm/pachyderm/blob/39561cec3328997919faa514600eecb53546ee3f/doc/pachctl/pachctl_deploy_custom.md

https://github.com/pachyderm/pachyderm/blob/39561cec3328997919faa514600eecb53546ee3f/doc/pachctl/pachctl_deploy_local.md

```bash
pachctl deploy custom \
  --persistent-disk google \
  --object-store \
    s3 \
    <persistent disk name> \
    <persistent disk size> \
    <object store bucket> \
    <object store id> \
    <object store secret> \
    <object store endpoint> \
  --static-etcd-volume=${STORAGE_NAME} \
  --dry-run \
    > deployment.json
```
```bash
./pachctl deploy custom \
  --persistent-disk <persistent disk backend> \
  --object-store <object store backend> <persistent disk args> <object store args>
```
