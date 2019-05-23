# Sample 1

GithubのWebhookとhookサービスのやりとりで完結するもの。プラグインの説明は[カタログ](https://prow.k8s.io/plugins)などに書いてある。

```
$ cp src/infra/manifests/plugins.yaml.sample1 src/infra/manifests/plugins.yaml
$ cp src/infra/manifests/config.yaml.sample1 src/infra/manifests/config.yaml
$ make check-conf # For mac user
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
