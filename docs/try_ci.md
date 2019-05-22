# Sample 2

PRを更新した時のPresubmitやマージ後のPostsubmitをトリガーにジョブを動かす[Trigger](plugins/trigger.md)プラグインを設定してCIを回す。

```
$ cp src/infra/manifests/plugins.yaml.sample2 src/infra/manifests/plugins.yaml
$ cp src/infra/manifests/config.yaml.sample2 src/infra/manifests/config.yaml
$ make check-conf # For mac user
```


* 書き換え

例えば`< org >/< repo >`を`gkuga/prow-handson`へ。< domain >をIngressのアドレスに。

Ingressのアドレスは↓
```
$ kubectl get ing
NAME   HOSTS   ADDRESS        PORTS   AGE
ing    *       34.96.87.188   80      140m
```

* 反映

```
$ make update-plugins
$ make update-config
```