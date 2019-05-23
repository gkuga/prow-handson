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

## プライベートリポジトリの場合

config.yamlのplankの設定にssh-keyの設定を追加。

```
  default_decoration_config:
    timeout: 4h
    grace_period: 15s
    utility_images:
      clonerefs: gcr.io/k8s-prow/clonerefs:v20190221-d14461a
      initupload: gcr.io/k8s-prow/initupload:v20190221-d14461a
      entrypoint: gcr.io/k8s-prow/entrypoint:v20190221-d14461a
      sidecar: gcr.io/k8s-prow/sidecar:v20190221-d14461a
    gcs_configuration:
      bucket: prow-handson-5963
      path_strategy: legacy
      default_org: "gkuga"
      default_repo: "prow-handson-private"
    gcs_credentials_secret: prow-sa-key
    ssh_key_secrets:
      - ssh-key
```

ジョブにも以下のようにsshの設定をする。

```
presubmits:
  gkuga/prow-handson:
  - name: test
    trigger: "(?m)^/test"
    rerun_command: "/test"
    context: test
    always_run: true
    agent: kubernetes
    decorate: true
    decoration_config:
      ssh_key_secrets:
        - ssh-key
    clone_uri: git@github.com:gkuga/prow-handson.git
```

このリポジトリのsecretsディレクトリにgithubの鍵を置いて`make create-ssh-key-secret`をするとファイルから鍵がクラスタにデプロイされるようにMakefileに記述している。
