# Jenkinsからの脱却

## Jenkins
* Jenkinsの問題点
    * Jenkinsのバージョンを上げるときに全て再起動する必要がある
    * Githubプラグインを使うのが難しい
* メンテナンスがしんどい
    * メモリリーク
    * スレーブの接続が切れる
    * fdの不足
    * Jenkinsおじさんだけがデバッグの仕方を知っている
* Prowへ
    * なんでK8sをテストするのにJenkins VMでやるのか？K8sのテストはK8sでやりたい
    * K8sだとメンテナンスもデプロイも楽にできる
    * ジョブをpodspecとして表現すれば、スケジューリングをK8sがしてくれる
    * Github webhookに対応できる。(mungithubよりも)
    * K8sをJenkinsより良く知っているし、何かあればSigチームの誰かつかまえてテストを改善するのに直してくれといえばいい

# なぜKubernetesを使っているのか
以下の理由によりCIとKubernetesは相性が良い。
* そのプロジェクトをテストするのに十分なくらいまでスケールできる
    * Kubernetesくらいの大きなプロジェクトでも大丈夫
        * https://k8s.devstats.cncf.io/d/12/dashboards?refresh=15m&orgId=1
* 障害耐性がある
    * 自動回復など
* CIに必要な機能が既にKubernetesに実装されている
    * コンテナのスケジューリングをしてくれるPods、リソースの管理をするCRD、設定を管理するConfigmapsや秘匿情報を管理するSecretsなど

## Kubernetesの統計情報 (KubeCon Europe 2018)
* 181 nodes, 1152 cores
* Scheduled 4.3 mil jobs last year
* 770 different jobs
* Set up presubmits for 31 repos

# プルリクエスト
プルリスクエストに伴い、以下がk8s上で動く。
* ビルドやテスト
* マージの自動化や、ChatOpsを実現するサービス

# ビルドやテストをPodsで動かすこと
コンテナなので
* 依存関係のあるものについて外部から影響を受けず、再現性がある。
* 開発者はビルド/テストをするコンテナイメージを用意すればよい。

## Podsの活用
* Secrets - 秘匿情報の管理
* Volumes - キャッシュ
* Init Containers - コードのチェックアウト
* Sidecar Containers - 結果のアップロード
* Pod presets - 設定の重複の削除
* Resource request - 効果的なスケジューリング

# CIのジョブの管理
ジョブの管理ではCRDを使う。従来のCIでは、マスターがジョブのキューを管理し、エージェントに指示することでジョブを実行する。Kubernetesではコントローラーにより分散的で宣言的にジョブが管理される。
カスタムコントローラーにより、様々なトリガーに対応させることができる。そしてKubernetes APIにより別のクラスターでジョブを実行するなど様々な実行環境に対応できる。ジョブのモニタリングや結果のレポートなどもカスタムコントローラーで実行できる。

# Configmaps
* Updateconfigプラグインにより再デプロイがいらない。

# Custom Controllersの開発
各カスタムコントローラーに変更があれば、イメージをビルド・プッシュしてステージングで動作テストを行う。

# PRで動くジョブの設定例
```
org/repo
- name: sample-presubmit-job
    always_run: true
    decorate: true
    spec:
        containers:
        - image: golang
            command:
            - go
            args:
            - test
            - ./...
```

# ジョブタイプ
* presubmit
...

# トリガーのメカニズム
* /test all
...

# 実行環境
* KubernetesのPods
* Knative Build
* Jenkins

# Reporting sinks
* GitHubのステータス
* Gerrit comment
* Pubsub message