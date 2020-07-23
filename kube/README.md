### NOTE

This deployment depends on two custom (public) Docker images:

1. docker.io/kthyagar/ktflink (Flink; see Dockerfile-flink)
2. docker.io/kthyagar/ktflinkzep (Zeppelin w/ embedded Flink; see Dockerfile-zep)

WARNING: These Docker images, and this entire deployment, is for illustration purposes only. Not for production use.

### Deploy flink

```
kubectl create -f svc-acct.yaml
kubectl create -f flink-configuration-configmap.yaml
kubectl create -f jobmanager-service.yaml
kubectl create -f jobmanager-deployment.yaml
kubectl create -f taskmanager-deployment.yaml
kubectl create -f jobmanager-rest-service.yaml
```

### Teardown flink

```
kubectl delete -f svc-acct.yaml
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

### Configure your EKS cluster with [fine-grained access control](https://aws.amazon.com/blogs/opensource/introducing-fine-grained-iam-roles-service-accounts/)
NOTE: This is not essential because we'll be using the node role to talk to Kinesis and S3. In the future, once support arrives in the Flink Kinesis Connector
and the Zeppelin container to handle WebIdentityCredentials, we'll switch to leveraging this IRSA setup

```
eksctl utils associate-iam-oidc-provider \
               --name [Your cluster] \
               --approve
```

```
... follow instructions in the blog to configure pod creds
```


### Deploy zeppelin
```
kubectl apply -f zeppelin-simple.yaml
```

### Use [kubectl port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/) to access Flink UI and Zeppelin UI
Flink:
```
kubectl port-forward [flink jobmanager podname] 8081:8081
```

Zeppelin:
```
kubectl port-forward [zeppelin podname] 8080:8080
```
