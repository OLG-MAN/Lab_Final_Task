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

5. Creating infrastructure. Configure kubectl.

```
terraform init

terraform validate

terraform plan

terraform apply

gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)

```

6. Install and configure Jenkins. 
* Create namespace.
* Add service accounts and RBAC.
* Add persistence volume and persistence volume claim.
* Apply jenkins deployment.
* Add Service to connect with jenkins and configure it.

```
kubectl create ns jenkins

kubectl -n jenkins apply -f jenkins/

#show jenkins pod name
kubectl -n jenkins get pods

#grab password to jenkins first time configure
kubectl -n jenkins logs <POD_NAME>

```

7. Install Kubernetes plugin.   