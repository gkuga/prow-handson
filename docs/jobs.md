
# ProwJobs

CIで行われるジョブはProwJobsとしてK8sのCRDにより定義されている。

## CustomResourceDefinition 
K8sのリソースを独自に定義できる仕組み。K8sの通常のリソースのように扱える。`kubectl get prowjobs`すると以下のようになる。

```
$ kubectl get prowjobs
NAME                                   JOB          BUILDID               TYPE         ORG     REPO          PULLS   STARTTIME   COMPLETIONTIME   STATE
09d7e553-7cc8-11e9-8f9f-2ad8025b9d54   postsubmit   1131281189525524480   postsubmit   gkuga   prow-handson           6h          6h               failure
21168afd-7cde-11e9-ba39-921b53acd1f4   echo-test    1131321077402701824   periodic                                    3h          3h               success
227df172-7cca-11e9-b710-be101b6cd066   postsubmit   1131284964478816256   postsubmit   gkuga   prow-handson           6h          6h               failure
2a3293d3-7cd3-11e9-8f9f-2ad8025b9d54   postsubmit   1131301322486714368   postsubmit   gkuga   prow-handson           5h          5h               failure
```

例えばK8sでは、ReplicaSetというリソースが作成されると、指定されたPodのレプリカ数を維持するようにPodリソースを調整するコントローラーというデーモンが動く。ProwではProwJobが作成されると、そこで指定されたジョブをPodリソースとして作成して実行して、成功ならステータスをSuccessにして失敗ならFailureにするなどしている。ProwJobの作成は、例えば定期的なジョブならばHorologiumサービスが作成し、PRが更新されるときはHookサービスのTriggerプラグインが作成する。作成されたジョブを実行するなど、ライフサイクルを管理するのはPlankサービスが行っている。

## 定期的なジョブの例
例えば定期的なジョブを実行したい時は以下のようにYAMLで書く。

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

上記の設定を見て、Horologiumが作成するProwJobは以下のようになる。

```
apiVersion: prow.k8s.io/v1
kind: ProwJob
metadata:
  annotations:
    prow.k8s.io/job: echo-test
  creationTimestamp: "2019-05-22T22:08:29Z"
  generation: 1
  labels:
    created-by-prow: "true"
    prow.k8s.io/id: 21168afd-7cde-11e9-ba39-921b53acd1f4
    prow.k8s.io/job: echo-test
    prow.k8s.io/type: periodic
  name: 21168afd-7cde-11e9-ba39-921b53acd1f4
  namespace: default
  resourceVersion: "194898"
  selfLink: /apis/prow.k8s.io/v1/namespaces/default/prowjobs/21168afd-7cde-11e9-ba39-921b53acd1f4
  uid: 2116ba62-7cde-11e9-8211-42010a920041
spec:
  agent: kubernetes
  cluster: default
  decoration_config:
    gcs_configuration:
      bucket: prow-handson-5963
      default_org: gkuga
      default_repo: prow-handson-private
      path_strategy: legacy
    gcs_credentials_secret: prow-sa-key
    grace_period: 10s
    ssh_key_secrets:
    - ssh-key
    timeout: 4h0m0s
    utility_images:
      clonerefs: gcr.io/k8s-prow/clonerefs:v20190221-d14461a
      entrypoint: gcr.io/k8s-prow/entrypoint:v20190221-d14461a
      initupload: gcr.io/k8s-prow/initupload:v20190221-d14461a
      sidecar: gcr.io/k8s-prow/sidecar:v20190221-d14461a
  job: echo-test
  namespace: test-pods
  pod_spec:
    containers:
    - command:
      - /bin/date
      image: alpine
      name: ""
      resources: {}
  type: periodic
  ```

  これによってPlankサービスは以下のようなPodを作成する。

  ```
  apiVersion: v1
kind: Pod
metadata:
  annotations:
    prow.k8s.io/job: echo-test
  creationTimestamp: "2019-05-23T02:08:58Z"
  labels:
    created-by-prow: "true"
    prow.k8s.io/id: a8284764-7cff-11e9-ba39-921b53acd1f4
    prow.k8s.io/job: echo-test
    prow.k8s.io/type: periodic
  name: a8284764-7cff-11e9-ba39-921b53acd1f4
  namespace: test-pods
  resourceVersion: "244029"
  selfLink: /api/v1/namespaces/test-pods/pods/a8284764-7cff-11e9-ba39-921b53acd1f4
  uid: b9a4e443-7cff-11e9-8211-42010a920041
spec:
  automountServiceAccountToken: false
  containers:
  - command:
    - /tools/entrypoint
    env:
    - name: ARTIFACTS
      value: /logs/artifacts
    - name: BUILD_ID
      value: "1131381475451604992"
    - name: BUILD_NUMBER
      value: "1131381475451604992"
    - name: GOPATH
      value: /home/prow/go
    - name: JOB_NAME
      value: echo-test
    - name: JOB_SPEC
      value: '{"type":"periodic","job":"echo-test","buildid":"1131381475451604992","prowjobid":"a8284764-7cff-11e9-ba39-921b53acd1f4"}'
    - name: JOB_TYPE
      value: periodic
    - name: PROW_JOB_ID
      value: a8284764-7cff-11e9-ba39-921b53acd1f4
    - name: ENTRYPOINT_OPTIONS
      value: '{"timeout":14400000000000,"grace_period":10000000000,"artifact_dir":"/logs/artifacts","args":["/bin/date"],"process_log":"/logs/process-log.txt","marker_file":"/logs/marker-file.txt","metadata_file":"/logs/artifacts/metadata.json"}'
    image: alpine
    imagePullPolicy: Always
    name: test
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /logs
      name: logs
    - mountPath: /tools
      name: tools
  - command:
    - /sidecar
    env:
    - name: JOB_SPEC
      value: '{"type":"periodic","job":"echo-test","buildid":"1131381475451604992","prowjobid":"a8284764-7cff-11e9-ba39-921b53acd1f4"}'
    - name: SIDECAR_OPTIONS
      value: '{"gcs_options":{"items":["/logs/artifacts"],"bucket":"prow-handson-5963","path_strategy":"legacy","default_org":"gkuga","default_repo":"prow-handson-private","gcs_credentials_file":"/secrets/gcs/service-account.json","dry_run":false,"extensions":{}},"entries":[{"args":["/bin/date"],"process_log":"/logs/process-log.txt","marker_file":"/logs/marker-file.txt","metadata_file":"/logs/artifacts/metadata.json"}]}'
    image: gcr.io/k8s-prow/sidecar:v20190221-d14461a
    imagePullPolicy: IfNotPresent
    name: sidecar
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /logs
      name: logs
    - mountPath: /secrets/gcs
      name: gcs-credentials
  dnsPolicy: ClusterFirst
  initContainers:
  - command:
    - /initupload
    env:
    - name: INITUPLOAD_OPTIONS
      value: '{"bucket":"prow-handson-5963","path_strategy":"legacy","default_org":"gkuga","default_repo":"prow-handson-private","gcs_credentials_file":"/secrets/gcs/service-account.json","dry_run":false,"extensions":{}}'
    - name: JOB_SPEC
      value: '{"type":"periodic","job":"echo-test","buildid":"1131381475451604992","prowjobid":"a8284764-7cff-11e9-ba39-921b53acd1f4"}'
    image: gcr.io/k8s-prow/initupload:v20190221-d14461a
    imagePullPolicy: IfNotPresent
    name: initupload
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /secrets/gcs
      name: gcs-credentials
  - args:
    - /entrypoint
    - /tools/entrypoint
    command:
    - /bin/cp
    image: gcr.io/k8s-prow/entrypoint:v20190221-d14461a
    imagePullPolicy: IfNotPresent
    name: place-entrypoint
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /tools
      name: tools
  nodeName: gke-prow-handson-clu-prow-handson-nod-9bc08c7c-2d5h
  priority: 0
  restartPolicy: Never
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  volumes:
  - emptyDir: {}
    name: logs
  - emptyDir: {}
    name: tools
  - name: gcs-credentials
    secret:
      defaultMode: 420
      secretName: prow-sa-key
```
