### NOTE

This deployment depends on two custom (public) Docker images:

1. docker.io/kthyagar/ktflink (Flink; see Dockerfile-flink)
2. docker.io/kthyagar/ktflinkzep (Zeppelin w/ embedded Flink; see Dockerfile-zep)

WARNING: These Docker images, and this entire deployment, is for illustration purposes only. Not for production use.

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

### install uswitch/kiam
NOTE: This is a stop-gap solution until the Flink Kinesis Connector supports WebIdentityTokenCredentialsProvider

https://github.com/uswitch/kiam

https://hub.helm.sh/charts/uswitch/kiam

```
helm install uswitch/kiam --generate-name --set agent.host.iptables=true
```

More information on setting up kiam: https://medium.com/@SreedharBukya/working-with-kiam-roles-in-kubernetes-1b16cf0e6b85

### install namespace annotation for kiam

```
kubectl apply -f kiam.namespace.default.yaml
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


### Deploy zeppelin
```
kubectl apply -f zeppelin-simple.yaml
```

### Use [kubectl port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/) to access Flink UI and Zeppelin UI
Flink:
```
kubectl port-forward [flink jobmanager podname] 81:8082
```

Zeppelin:
```
kubectl port-forward [zeppelin podname] 80:8081
```
