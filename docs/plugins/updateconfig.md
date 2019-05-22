# Updateconfig

## 設定
```
config_updater:
  maps:
    label_sync/labels.yaml:
      name: label-config
      namespace: test-pods
    prow/config.yaml:
      name: config
    prow/plugins.yaml:
      name: plugins
    config/jobs/**/*.yaml:
      name: job-config
      gzip: true
    experiment/test-configmap.txt:
      name: test-configmap
      gzip: true
```