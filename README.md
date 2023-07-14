# K8s_Dashboard
The Docker image used in **deployment.yaml** is located in my DockerHub repository: [ericlong07/shiny-app](https://hub.docker.com/r/ericlong07/shiny-app/tags).

## To run the app on Minikube
You will need to have `minikube` and `kubectl` installed.
See Kubernetes' [Install tools](https://kubernetes.io/docs/tasks/tools/#kubectl) page for installation instructions.

1. `minikube start` to create a minikube cluster
2. Deploy the deployment `kubectl apply -f deployment.yaml` and service `kubectl apply -f service.yaml`
3. `minikube service shiny-app-service` will open a web browser to the service (you can also add the `--url` flag at the end to display the URL to access the service without opening it in a web browser)

## Alternative ways to access the app

### Using port forwarding
1. Run `kubectl port-forward service/shiny-app-service 3838:80` and then go to `http://localhost:3838`

### With an ingress
1. `kubectl apply -f ingress.yaml`
2. `minikube addons enable ingress` to install NGINX's ingress controller (their [GitHub page](https://github.com/kubernetes/ingress-nginx/tree/main))
3. Run `minikube tunnel` and your ingress resources would be available at "**127.0.0.1**"

## To check the status of
- Deployments: `kubectl get deployments`
- Services: `kubectl get services`
- ReplicaSets: `kubectl get rs`
- Pods: `kubectl get pods`
- Ingresses: `kubectl get ingresses`

To list all the nodes and pods in your cluster:
```
kubectl get nodes
kubectl get pods --all-namespaces
```

## Scaling the app
1. `kubectl scale deployments/shiny-app --replicas=<desired_amount>`

## To delete a specific pod
1. `kubeclt delete pod <pod_name>`

## Clean up
When finished, clean up the resources created in your cluster and stop Minikube (or if you no longer need Minikube, `minikube delete` to remove the Minikube cluster and all the Kubernetes nodes, pods, services, and other resources associated with it).
```
kubectl delete deployment shiny-app
kubectl delete service shiny-app-service
```

If an ingress was used, delete it as well:
```
kubectl delete deployment ingress-nginx-controller -n ingress-nginx
kubectl delete service ingress-nginx-controller -n ingress-nginx
kubectl delete namespace ingress-nginx
kubectl delete ingress shiny-app-ingress
```

Finally, `minikube stop`
