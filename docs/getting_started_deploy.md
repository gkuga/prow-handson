# ハンズオン用のリポジトリ
[gkuga/prow-handson](https://github.com/gkuga/prow-handson)のリポジトリをフォークして使う。

# Prowのインストール
ProwはKubernetes上で動くのでクラスターを用意する必要がある。Prowにはデプロイ用に作られた`tackle`というツールを使う方法と手動で行う方法がある。tackleを始め、ProwのツールはGCPを対象に作られているが、ProwはGKEに限らないKubernetesで動作する。

## 手動によるデプロイ

### 1. クラスターの作成

* GCPプロジェクトを作成する。
```
$ gcloud projects create prow-handson-$( perl -e 'printf ("%04d\n",rand(10000))' ) --set-as-default
```

* 環境変数の設定
```
$ gcloud projects list
$ gcloud beta billing accounts list
$ cp .env.sample .env
$ vi .env
$ . .env
```

* リソースの作成
```
$ make create-terraform-sa
$ make enable-apis
$ make init
$ make plan
$ make apply
```

* 認証
```
$ make get-cluster-credentials
$ kubectl get nodes
NAME                                                  STATUS   ROLES    AGE   VERSION
gke-prow-handson-clu-prow-handson-nod-9bc08c7c-0jl5   Ready    <none>   11h   v1.12.7-gke.10
gke-prow-handson-clu-prow-handson-nod-9bc08c7c-2d5h   Ready    <none>   11h   v1.12.7-gke.10
```

### 2. Githubのトークンの作成

* Webhook検証用のトークン

```
$ make generate-hmac-token
$ make create-hmac-token-secrete
```

* Prowボット用のトークン

[Github](https://github.com/settings/tokens)にアクセスしてトークンを作成。Scopeは`repo:status`, ` repo_deployment`, `public_repo`にチェック。
```
$ echo 'generated token' > secrets/oauth-token
$ make create-oauth-token-secrete
```

### 3. Prowのデプロイ

* デプロイ

```
$ kubectl apply -f src/infra/manifests/starter.yaml
$ kubectl get deployments
NAME               DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deck               2         2         2            2           3m
hook               2         2         2            2           3m
horologium         1         1         1            1           3m
plank              1         1         1            1           3m
sinker             1         1         1            1           3m
statusreconciler   1         1         1            1           3m
tide               1         1         1            1           3m
```

* ipアドレスを確認してアクセス

```
$ kubectl get ingress ing
NAME   HOSTS   ADDRESS        PORTS   AGE
ing    *       xx.xx.xx.xxx   80      3m
```

### 4. Webhookの設定
Githubのフォークしたプロジェクトの設定からWebhookを設定。

* Payload URL

```
http://<your ingress address>/hook
```

* Content type

```
application/json
```

* Secret

```
<generated token for webhook>
```

* Which events would you like to trigger this webhook?

```
Send me everything.
```
## tackleによるデプロイ

1. tackleのインストール
tackleを実行する方法は2つ。一つは`kubernetes/test-infra`リポジトリをクローンして、`bazel`というビルドツールを使って`tackle`を実行する方法。もう一つは`go get -u k8s.io/test-infra/prow/cmd/tackle`により`tackle`をインストールして使う方法。公式では`bazel`の使用が推奨されている。`go get`によりインストールする方が実行が軽くて使いやすい。

2. GithubのPersonal access tokensの作成
このアクセストークンを使ってProwはGithub botとして動作する。Organization用のアカウントにBot用のユーザを作るか、個人のリポジトリで自分のアカウントでアクセストークンを作成する。
