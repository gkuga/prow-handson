# Sample 1

GithubのWebhookとhookサービスのやりとりで完結するもの。プラグインの説明は[カタログ](https://prow.k8s.io/plugins)などに書いてある。

```
$ cp src/infra/manifests/plugins.yaml.sample1 src/infra/manifests/plugins.yaml
$ cp src/infra/manifests/config.yaml.sample1 src/infra/manifests/config.yaml
```

* 書き換え

↑でコピーしたplugins.yamlに`< org >/< repo >`とあるので、自分のリポジトリ名へ。(例えば`gkuga/prow-handson`)

```
$ vi src/infra/manifests/plugins.yaml
```

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
