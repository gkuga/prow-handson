ハンズオンで個人のGCPアカウントを使うので先にこちらを見て下さい！

* [GCPの課金トラブル共有](https://docs.google.com/presentation/d/1xnizaHytFx4pf58A-V4OqoGsG4RKdHO89rRwky72sH0/edit)

ハンズオンではGKE(Google Container Engine)にKubernetesクラスターを作成しProwをデプロイするのに以下を使う。GCP(Google Cloud Platform)の無料トライアルを使う時は会社のアカウントではなく、個人のアカウントを使う。会社のアカウントで無料トライアルを有効にすると組織のアカウントがダウングレードされるので間違わないように注意。

* 個人のGoogleアカウント
* gcloudコマンド
* terraformコマンド
* kubectlコマンド

# Googleアカウント
個人のGoogleアカウントがなければ作成する。GCPを使ったことがない場合は[GCP Console](https://console.cloud.google.com)にアクセスして、利用規約などに同意し、無料トライアルを有効にしておく。その時、右上に今ログインしているアカウントが表示されるので、個人のアカウントに切り替える。

# gcloudコマンド
[gcloudコマンドラインツール](https://cloud.google.com/sdk/gcloud/?hl=ja)をインストールする。[公式](https://cloud.google.com/sdk/docs/?hl=ja#install_the_latest_cloud_tools_version_cloudsdk_current_version)からダウンロードするか[Homebrew Cask](https://github.com/Homebrew/homebrew-cask)でも`brew cask install google-cloud-sdk`でインストールできる。

```
$ curl -LO https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-240.0.0-darwin-x86_64.tar.gz
$ tar -xf google-cloud-sdk-240.0.0-darwin-x86_64.tar.gz
$ ./google-cloud-sdk/install.sh
```

## gcloudコマンドの設定

gcloudコマンドが使えるように認証をする。ブラウザを開いて作成した個人アカウントで認証する。
```
$ gcloud auth login
Your browser has been opened to visit:

    https://accounts.google.com/o/oauth2/auth?redirect_uri=xxxx...
```

認証したアカウントがACTIVEになれば成功。
```
$ gcloud auth list
       Credentialed Accounts
ACTIVE  ACCOUNT
        xxxx.xxxx@xxxx.xxx
*       xxxx.xxxx@xxxx.xxx
        xxxx_xxxx@xxxx.xx.xx
```

アカウントの切り替えは以下
```
$ gcloud config set account xxxx_xxxx@xxxx.xx.xx
```

# terraformコマンド
環境構築にインフラのコード化ツールである[Terraform](https://www.terraform.io)を使う。[Download Terraform](https://www.terraform.io/downloads.html)からダウンロードしてコマンドパスが通った場所に入れる。Homebrewでも`brew install terraform`でインストールできる。

```
$ curl -LO https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_darwin_amd64.zip
$ unzip terraform_0.11.14_darwin_amd64.zip
$ sudo mv ./terraform /usr/local/bin/terraform
$ terraform version
```

# kubectlコマンド
[Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)からか、`brew install kubernetes-cli`でインストール。

```
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version
```
