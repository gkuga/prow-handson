
# Deck

* ProwJobの現在のステータス
* プラグインやコマンドのヘルプ
* マージ自動化のステータス
* PR作成者用のタッシュボード

## Yaml
```yaml
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  namespace: default
  name: deck
  labels:
    app: deck
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: deck
    spec:
      serviceAccountName: "deck"
      terminationGracePeriodSeconds: 30
      containers:
      - name: deck
        image: gcr.io/k8s-prow/deck:v20190411-24aefcb76
        args:
        - --config-path=/etc/config/config.yaml
        - --tide-url=http://tide/
        - --hook-url=http://hook:8888/plugin-help
        ports:
          - name: http
            containerPort: 8080
        volumeMounts:
        - name: config
          mountPath: /etc/config
          readOnly: true
        livenessProbe:
          httpGet:
            path: /healthz
            port: 8081
          initialDelaySeconds: 3
          periodSeconds: 3
        readinessProbe:
          httpGet:
            path: /healthz/ready
            port: 8081
          initialDelaySeconds: 10
          periodSeconds: 3
          timeoutSeconds: 600
      volumes:
      - name: config
        configMap:
          name: config
---
apiVersion: v1
kind: Service
metadata:
  namespace: default
  name: deck
spec:
  selector:
    app: deck
  ports:
  - port: 80
    targetPort: 8080
  type: NodePort
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  namespace: default
  name: ing
spec:
  rules:
  - http:
      paths:
      - path: /* # Correct for GKE, need / on many other distros
        backend:
          serviceName: deck
          servicePort: 80
      - path: /hook
        backend:
          serviceName: hook
          servicePort: 8888
---
kind: ServiceAccount
apiVersion: v1
metadata:
  namespace: default
  name: "deck"
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: default
  name: "deck"
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: "deck"
subjects:
- kind: ServiceAccount
  name: "deck"
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: default
  name: "deck"
rules:
  - apiGroups:
      - ""
    resources:
      - pods/log
    verbs:
      - get
  - apiGroups:
      - "prow.k8s.io"
    resources:
      - prowjobs
    verbs:
      - get
      - list
```

