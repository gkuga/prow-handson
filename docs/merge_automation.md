# Sample 3

```
$ cp src/infra/manifests/plugins.yaml.sample3 src/infra/manifests/plugins.yaml
$ cp src/infra/manifests/config.yaml.sample3 src/infra/manifests/config.yaml
$ make check-conf # For mac user
$ make update-plugins
$ make update-config
```

* 書き換え

例えば`< org >/< repo >`を`gkuga/prow-handson`へ。< domain >をIngressのアドレスに。

Ingressのアドレスは↓
```
$ kubectl get ing
NAME   HOSTS   ADDRESS        PORTS   AGE
ing    *       xx.xx.xx.xxx   80      140m
```

* 反映

```
$ make update-plugins
$ make update-config
```

# Tideの設定

config.yaml.sample3にはTideの下記のような設定が追加されている。下記によりorg/repoには`lgtm`ラベルと`approved`ラベルがつけられていて、テストが通っていれば自動でマージされる。`missingLabels:`で指定されているラベルが付いている場合はマージがされない。また、`squash`でマージされる。

```
tide:
  sync_period: 1m
  queries:
  - repos:
    - < org >/< repo >
    labels:
    - lgtm
    - approved
    missingLabels:
    - do-not-merge
    - do-not-merge/hold
    - do-not-merge/invalid-owners-file
    - do-not-merge/work-in-progress
  merge_method:
    < org >/< repo >: squash
 ```
