# DevOps Project for Docker Deployment

This project automates the process of building Docker images, pushing them to Azure Container Registry (ACR), updating Kubernetes manifests, and deploying the application to Azure Kubernetes Service (AKS). 

The entire workflow is managed by GitHub Actions, which runs on an Azure virtual machine, ensuring high security throughout the CI/CD pipeline. The workflow includes steps for building the Docker image, logging into ACR, pushing the image, updating the Kubernetes manifests with the new image tag, and applying the changes to the AKS cluster.

By using this setup, you can efficiently manage and deploy your applications in a secure and automated manner.
