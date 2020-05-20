### Deploy flink

```
kubectl create -f flink-configuration-configmap.yaml
kubectl create -f jobmanager-service.yaml
kubectl create -f jobmanager-deployment.yaml
kubectl create -f taskmanager-deployment.yaml
kubectl create -f jobmanager-rest-service.yaml
```

### Teardown flink

```
kubectl delete -f jobmanager-rest-service.yaml
kubectl delete -f taskmanager-deployment.yaml
kubectl delete -f jobmanager-deployment.yaml
kubectl delete -f jobmanager-service.yaml
kubectl delete -f flink-configuration-configmap.yaml
```

### Deploy [EBS CSI Driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html)
- Follow instructions in https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html (first part; just the deployment of the driver)


### Deploy storageClass and ebs-claim

```
kubectl apply -f storageClass.yaml
kubectl apply -f ebs-claim.yaml
```

### Apply config map

```
kubectl kustomize  | kubectl apply -f -
```

### Deploy zeppelin
```
kubectl apply -f zeppelin-simple.yaml
```

### Copy interpreter settings to pod
```
kubectl cp --no-preserve=true ./flink-interpreter-setting.json [podname]:/zeppelin/interpreter/flink/interpreter-setting.json
```

### Use [kubectl port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/) to access Flink UI and Zeppelin UI
Flink:
```
kubectl port-forward [podname] 81:8081
```

Zeppelin:
```
kubectl port-forward [podname] 82:8080
```

### Configure your EKS cluster with [fine-grained access control](https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/)
```
eksctl utils associate-iam-oidc-provider \
               --name [Your cluster] \
               --approve
```

Give the role access to write to Kinesis
```
eksctl create iamserviceaccount \
                --name [Name for service account] \
                --namespace default \
                --cluster [Your cluster] \
                --attach-policy-arn arn:aws:iam::aws:policy/AmazonKinesisFullAccess \
                --approve
```