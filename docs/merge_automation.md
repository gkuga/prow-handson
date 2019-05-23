# Sample 3

```
$ cp src/infra/manifests/plugins.yaml.sample3 src/infra/manifests/plugins.yaml
$ cp src/infra/manifests/config.yaml.sample3 src/infra/manifests/config.yaml
```

* 書き換え

Sample 1と同様にplugins.yamlの`< org >/< repo >`を自分のアカウント名/リポジトリ名へ書き換える。また、config.yamlに`< domain >`というところがあるので、Ingressのアドレスに(`kubectl get ing`で確認できる）。`< bucket >`はGCPのプロジェクトIDへ（バケット名はプロジェクトIDで作成されている。`gcloud config list`でプロジェクトIDは確認できる。）。`< org >`は自分のアカウント名`< repo >`はリポジトリ名へ。

* 反映

下記でエラーが出ないかチェック。

```
$ make check-conf # For mac user
```

エラーがなければ下記で反映。

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
