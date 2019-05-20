
# Horologium
* 定期的なジョブを実行する
* robfig/cronを使って定期的にProwJobを作成するというシンプルなもの。

## デプロイのサンプル

```yaml
kind: ConfigMap
metadata:
  name: config
data:
  config.yaml: |
    periodics:
    - interval: 10m
      agent: kubernetes
      name: echo-test
      spec:
        containers:
          - image: alpine
            command: ["/bin/date"]
apiVersion: extensions/v1beta1
---
kind: Deployment
metadata:
  namespace: default
  name: horologium
  labels:
    app: horologium
spec:
  replicas: 1 # Do not scale up.
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: horologium
    spec:
      serviceAccountName: "horologium"
      terminationGracePeriodSeconds: 30
      containers:
      - name: horologium
        image: gcr.io/k8s-prow/horologium:v20190411-24aefcb76
        args:
        - --config-path=/etc/config/config.yaml
        volumeMounts:
        - name: config
          mountPath: /etc/config
          readOnly: true
      volumes:
      - name: config
        configMap:
          name: config
---
kind: ServiceAccount
apiVersion: v1
metadata:
  namespace: default
  name: "horologium"
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: default
  name: "horologium"
rules:
  - apiGroups:
      - "prow.k8s.io"
    resources:
      - prowjobs
    verbs:
      - create
      - list
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: default
  name: "horologium"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: "horologium"
subjects:
- kind: ServiceAccount
  name: "horologium"
```

## ProwJobのサンプル
* Horologiumが生成するProwJob

```yaml
あとでget prowjob -o yamlしたやつ貼り付ける
```