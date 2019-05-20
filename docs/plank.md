
# Plank
* ジョブのライフサイクルを管理する。
* 30秒ごとにProwJobsを監視
* トリガーされたジョブを見つけて、podを作成して実行する。Podのステータスを見て、ProwJobのステータスを変更する。

## Yaml

```yaml
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  namespace: default
  name: plank
  labels:
    app: plank
spec:
  replicas: 1 # Do not scale up.
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: plank
    spec:
      serviceAccountName: "plank"
      containers:
      - name: plank
        image: gcr.io/k8s-prow/plank:v20190411-24aefcb76
        args:
        - --dry-run=false
        - --config-path=/etc/config/config.yaml
        volumeMounts:
        - name: oauth
          mountPath: /etc/github
          readOnly: true
        - name: config
          mountPath: /etc/config
          readOnly: true
      volumes:
      - name: oauth
        secret:
          secretName: oauth-token
      - name: config
        configMap:
          name: config
---
kind: ServiceAccount
apiVersion: v1
metadata:
  namespace: default
  name: "plank"
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: default
  name: "plank"
rules:
  - apiGroups:
      - ""
    resources:
      - pods
    verbs:
      - create
      - delete
      - list
  - apiGroups:
      - "prow.k8s.io"
    resources:
      - prowjobs
    verbs:
      - get
      - create
      - list
      - update
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: default
  name: "plank"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: "plank"
subjects:
- kind: ServiceAccount
  name: "plank"
---

# Plank 設定

## allow_cancellations
ジョブが実行された時、既に同じPRで実行中のジョブがあれば削除するかどうか。
kkgg
## job_url_prefix
Pod Utilitiesを使うジョブの結果のURLにつけるプレフィックス。

## job_url_template
Pod Utilitiesを使わないジョブの結果のURLにつけるプレフィックス。

## report_template

## default_decoration_config
Pod Utilitiesを使うジョブのデフォルトの設定。

### timeout
ナノ秒で指定。この値を超えるとジョブはタイムアウトで停止する。

### grace_period
ナノ秒で指定。タイムアウト後の猶予期間。

### utility_images
ジョブの実行に使われるツール
* clonerefs
    * テスト時にソースコードをクローンする
* initupload
    * GCSにテストの初期値などを保存
* entrypoint
    * テストのログや結果を記録するためにテストコンテナに注入される
* sidecar
    * テストコンテナのサイドカーとして動く。テストが終わると、ジョブのステータスやログ、テストの生成物をGCSへ保存。

## gcs_configration
ジョブの結果をGCSへアップロードするための設定

### bucket
### path_strategy
### default_org
### default_repo

## gcs_credentials_secret
## ssh_key_secrets