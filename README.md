# K8s_Dashboard
The Docker image used to run the shiny-app is located in my DockerHub repository: [ericlong07/shiny-app](https://hub.docker.com/r/ericlong07/shiny-app/tags).

## To run the app on Minikube
You will need to have `minikube` and `kubectl` installed.
See Kubernetes' [Install tools](https://kubernetes.io/docs/tasks/tools/#kubectl) page for installation instructions.

1. `minikube start` to create a minikube cluster
2. Create the deployment `kubectl apply -f deployment.yaml` and service `kubectl apply -f service.yaml`
3. Use `kubectl get service shiny-app-service` to get the **EXTERNAL-IP** for accessing the app

### If there is no EXTERNAL_IP assigned to the service
Use port forwarding to access the app instead.

1. Run `kubectl port-forward service/shiny-app-service 3838:80` and then go to `http://localhost:3838`

## To check the status of
- Deployments: `kubectl get deployments`
- Services: `kubectl get services`
- ReplicaSets: `kubectl get rs`
- Pods: `kubectl get pods`

## Scaling the app
1. `kubectl scale deployments/shiny-app --replicas=<desired_amount>`

## To delete a specific pod
1. `kubeclt delete pod <pod_name>`

## Clean up
When finished, clean up the resources created in your cluster and stop Minikube.
```
kubectl delete deployment shiny-app
kubectl delete service shiny-app-service
minikube stop
```
