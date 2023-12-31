# K8s Dashboard and Database
The Docker images used in each of the **deployment.yaml** are located in [my DockerHub repository](https://hub.docker.com/r/ericlong07/shiny-app/tags).

## Running the app on Minikube
You will need to have `minikube` and `kubectl` installed.
See Kubernetes' [Install tools](https://kubernetes.io/docs/tasks/tools/#kubectl) page for installation instructions.

1. `minikube start` to initialize a kubernetes cluster
2. Deploy the deployment and service of both the Shiny dashboard and Postgres database:
    ```
    kubectl apply -f ./dashboard/deployment.yaml
    kubectl apply -f ./dashboard/service.yaml
    kubectl apply -f ./database/deployment.yaml
    kubectl apply -f ./database/service.yaml
    ```
3. `minikube service shiny-app-service` will open a web browser to the application

## Alternative ways to access the app

### Using port forwarding
1. Run `kubectl port-forward service/shiny-app-service 3838:80` and then go to `http://localhost:3838`

### With an ingress
1. `kubectl apply -f ./dashboard/ingress.yaml`
2. `minikube addons enable ingress` to install NGINX's ingress controller (their [GitHub page](https://github.com/kubernetes/ingress-nginx/tree/main))
3. Run `minikube tunnel` and your ingress resources will be available at **127.0.0.1**

## To check the status of
- Deployments: `kubectl get deploy`
- Services: `kubectl get svc`
- ReplicaSets: `kubectl get rs`
- Pods: `kubectl get po`
- Ingresses: `kubectl get ing`
- PersistentVolumes: `kubectl get pv`
- PersistentVolumeClaims: `kubectl get pvc`

To list all the nodes and pods in your cluster (or any of the above resources by adding the `--all-namespaces` flag):
```
kubectl get no
kubectl get po --all-namespaces
```

## Scaling the app
```
kubectl scale deployments/shiny-app --replicas=<desired_amount>
kubectl scale deployments/postgres-deployment --replicas=<desired_amount>
```

## Deleting a specific resource
1. `kubeclt delete <type> <name>`

You can also do `kubectl delete <type> -all -n <namespace>` to delete all instances of one type of resource in a specified namespace.

## Debugging tips
### Check the logs of a pod
```
kubectl logs <pod_name>
```
You could also do `kubectl describe pod <pod_name>` which will give more technical information regarding the pod itself.

### Connect to the Postgres database internally
```
kubectl exec -it <postgres_pod_name> -- psql -U postgres
```
You can then use commands like `\l` to list all available databases, `\c <database_name>` to connect to a specific database, and `\dt` to list all available tables. You will also be able to perform standard SQL queries. Type `exit` to end the connection.

### Bash into a running container
```
kubectl exec -it <pod_name> -- /bin/bash
```
Once inside, utilize `ls` and `cd` to list and search through the available directories within the container. `exit` to terminate the command.

## Clean up
When finished, clean up the resources created in your cluster and stop Minikube (or if you no longer need Minikube, `minikube delete` to remove the Minikube cluster and all the Kubernetes nodes, pods, services, and other resources associated with it).
```
kubectl delete deploy shiny-app
kubectl delete svc shiny-app-service
kubectl delete deploy postgres-deployment
kubectl delete svc postgres-service
kubectl delete pvc postgres-pvc
kubectl delete pv <pv_name>
```

If an ingress was used, delete it as well (the following code is specifically for **NGINX**'s ingress controller):
```
kubectl delete deployment ingress-nginx-controller -n ingress-nginx
kubectl delete service ingress-nginx-controller -n ingress-nginx
kubectl delete namespace ingress-nginx
kubectl delete ingress shiny-app-ingress
```

Finally, `minikube stop`
