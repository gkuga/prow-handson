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
ing    *       xx.xx.xx.xxx   80      140m
```

* 反映

```
$ make update-plugins
$ make update-config
```

# Triggerプラグイン
plugins.yaml.sample2にはtriggerプラグインを追加している。これにより`presubmits`と`postsubmits`が動作するようになる。config.yaml.sample2ではその設定を記述している。例えば定期的なジョブは以下。

```
periodics:
- interval: 60m
  name: echo-test
  decorate: true
  spec:
    containers:
    - image: alpine
      command: ["/bin/date"]
```

PRが更新されるときに実行されるジョブは以下。

```
presubmits:
  < org >/< repo >:
  - name: test
    trigger: "(?m)^/test"
    rerun_command: "/test"
    context: test
    always_run: true
    agent: kubernetes
    decorate: true
    spec:
      containers:
      - image: golang:1.12.5-stretch
        command: ["make", "test"]
```
