# Lab Final Task

## Summary

### Creating infrastructure and CI/CD for Web-app.

* Use VSCode and create working docker container with needed tools inside.
* Provisioning GKE cluster and resource through Terraform.
* Configure cluster.
* Install and Configure Jenkins. Making CI/CD pipeline.
* Install Monitoring and make DNS address configuration.

### Using tools and techs

* Git/GitHub
* Docker/DockerHub
* Terraform
* GCP/GKE
* Jenkins
* Prometheus/Grafana

### Use terrafrom to create infrastructure on GCP.

1. Using google cloud-sdk docker image. Build working container based on image, install TF. 
2. Starting container (cloud-sdk+tf) and attach working directory to container.

```
docker run -it --rm -v ${PWD}:/work -w /work <IMAGE_NAME>
```

3. Autheticate with GCP project, choose project for working. 

```
gcloud auth login
gcloud config set project PROJECT_ID
```

4. Creating service account for terraform, create .json key and use it in .tf files.

5. Creating infrastructure. GKE cluster and gce-disk for Jenkins. Configure kubectl.

```
terraform init
terraform validate
terraform plan
terraform apply
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)
```
### Jenkins CI/CD.

6. Install and configure Jenkins. 
* Create namespace.
* Add service accounts and RBAC.
* Add persistence volume and persistence volume claim.
* Apply jenkins deployment.
* Add Service to connect with jenkins and configure it.

```
kubectl create ns jenkins
#apply all items like pv, pvc, rbac, sa, jenkins-master pod
kubectl -n jenkins apply -f jenkins/
#show jenkins pod name
kubectl -n jenkins get pods
#grab password to jenkins first time configure
kubectl -n jenkins logs <POD_NAME>
```

7. Install Kubernetes and configure plugin.

* Installing `kubernetes-plugin` for Jenkins and restart
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
              (SSH to VM and grab id's by commands 'cat /etc/passwd' 'cat /etc/group')
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
* Create pipeline job
* Add webhook trigger to github repo of project
* Choose pipeline script from SCM | add repo | edit branch if need | choose Jenkins file.
* Pipeline code we can find in Jenkinsfile

### Check web-app

9. Check Deployment resources

```
#check all new created resources in namespace
kubectl -n jenkins get all
#grab Loadbalancer externalIP to find our deployment web-app 
```

10. Monitoring