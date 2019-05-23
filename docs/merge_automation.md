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
