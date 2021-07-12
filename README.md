# Lab Final Task

## Summary

### Cloud k8s infrastructure and CI/CD for web-app.

* Working environment - vscode and docker container with needed tools inside.
* Provisioning GKE cluster and resource through Terraform.
* Configure cluster.
* Install and configure Ingress.
* Install and Configure Jenkins. 
* Making CI/CD pipeline.
* Install Monitoring.

### Using tools and techs

* Git/GitHub
* Docker/DockerHub
* Terraform
* GCP/GKE
* Jenkins
* Helm
* Prometheus/Grafana
* Contour Ingress controller

## Steps

### Use terrafrom to create infrastructure on GCP.

1. Using google cloud-sdk docker image. Build working container based on image, install TF. 
2. Starting container (cloud-sdk + tf) and attach working directory to container.

```
docker run -it --rm -v ${PWD}:/work -w /work <IMAGE_NAME>
```

3. Autheticate with GCP project, choose project for working. 

```
gcloud auth login
gcloud config set project PROJECT_ID
```

4. Creating service account for terraform, create .json key and use it in .tf files.
- Create service account. In IAM & Admin menu.
- Type <NAME>
- Give Role - Project - Owner
- Create key (JSON format), key will automaticaly downloaded
- use this key in .tf file in provider credentials

5. Creating infrastructure. GKE cluster and gce-disk for Jenkins. Configure kubectl.

```
#go to terraform folder 
cd terraform/

#initialize terraform, check and apply terraform files
terraform init
terraform validate
terraform plan
terraform apply

#get cluster credentials, configure .kubeconfig
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)
```

### Install Ingress and configure Cloud DNS

* Install Contour Ingress Controller

```
#deploy ingress
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
```

* Prepare DNS address. We can register a free domain name like example.pp.ua
* Create zone for domain in Cloud DNS
* Configure domain name NS records which provide in Cloud DNS
* Create records in Cloud DNS for differents services in this task (like jenkins, test-app env, prod-app env).
* Configure ingress file for backend services (file in ingress folder).
* After installing each services (jenkins, prod, test) in their namespaces,  
  apply ingress file in each namespace with uncomment part of codes in file. 
  (All instructions in comments ingress-hosts.yaml)


### Jenkins CI/CD.

6. Install and configure Jenkins. 
* Create namespace.
* Add service accounts and RBAC.
* Add persistence volume and persistence volume claim.
* Apply jenkins deployment.
* Add Service to connect with jenkins and configure it.

```
#create namespace for Jenkins
kubectl create ns jenkins

#apply all items like pv, pvc, rbac, sa, jenkins-master pod
kubectl -n jenkins apply -f jenkins/

#show jenkins pod name
kubectl -n jenkins get pods

#grab password to jenkins first time configure
kubectl -n jenkins logs <POD_NAME>
```

7. Install Kubernetes and configure plugin.

* Installing `kubernetes-plugin` for Jenkins and restart it.
* Go to Manage Jenkins | Manage Nodes and Clouds | Configure Cloud | Kubernetes (Add kubernetes cloud) | Details
* Fill out plugin values
    * Name: kubernetes
    * Kubernetes URL: https://kubernetes.default:443
    * Kubernetes Namespace: jenkins
    * Credentials | Add | Jenkins (Choose Kubernetes service account option & Global + Save)
    * Test Connection | Should be successful! If not, check RBAC permissions and fix it!
    * Jenkins URL: http://jenkins
    * Tunnel : jenkins:50000
    * Add Kubernetes Pod Template
        * Name: jenkins-slave | templates details
        * Namespace: jenkins
        * Labels: jenkins-slave (you will need to use this label on all jobs)
        * Add Containers | Add Container Template
            * Name: jnlp
            * Docker Image: aimvector/jenkins-slave
            * Command to run : <Make this blank>
            * Arguments to pass to the command: <Make this blank>
            * Allocate pseudo-TTY: yes
            * Advanced | User ID : <docker id> | GroupID : <docker group> 
              (SSH to VMs and grab id's and groups by commands 'cat /etc/passwd' and 'cat /etc/group')
            * Add Volume
                * HostPath type
                * HostPath: /var/run/docker.sock
                * Mount Path: /var/run/docker.sock
                * in Bottom of Page | 
                * Service Account : jenkins 
                * User ID : <docker id>
                * GroupID : <docker group>
* Save

8. CI/CD Pipeline
* Create two namespaces for deployments in k8s cluster - 'test' and 'prod'.

```
kubectl create ns test
kubectl create ns prod
```

* Create pipeline job
* Add webhook trigger to github repo of project
* Choose pipeline script from SCM | add GitHub repo | edit branch if need | choose Jenkins file.
* Pipeline code we can find in Jenkinsfile

* When we make a build, first pipeline create a deployment in 'test' namespace and we can check web-app here.
  After I use 'milestone' and we can continue deploy to 'prod' namespace if web-app in 'test' is OK.
  If NOT, we can abort deploy to 'prod' namespace. And fix some issues in web-app or in a build.

### Check web-app

9. Check Deployment resources.

```
#check all new created resources in namespace
kubectl -n <NAMESPACE> get all
```

* Configure Ingress file for each namespace.

* Go to each address to check different environments.

### Install and configure Monitoring for k8s cluster

10. Monitoring

* Install Helm 

```
#install helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

#check helm
helm version
```

* Add prometheus-community helm chart in K8s cluster.

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

* Install prometheus-community/kube-prometheus-stack

```
#we can check latest version in https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
helm install my-kube-prometheus-stack prometheus-community/kube-prometheus-stack --version 16.12.1
```

* Check pods and services that created.

```
#check pods and services in defalt namespace
kubectl get pods 
kubectl get svc
```

* Edit Prometheus and Grafana services to have access and configure it.

```
#edit services change type to LoadBalancer
kubectl edit svc my-kube-prometheus-stack-grafana
kubectl edit svc my-kube-prometheus-stack-prometheus

#check and grab IP's from prometheus and grafana
kubectl get svc
```

* Go to LoadBalancer IP of Grafana to configure it.

- Data sources already configured to Prometheus
- We can click to dashboard | manage | Choose Resource for Monitoring

----------------------------------------------------------------------