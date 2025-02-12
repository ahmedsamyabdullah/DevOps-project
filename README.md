# DevOps-project ivolve
## Prepared By Ahmed Samy
*** 
# Phase 1: Infrastructure Setup with Terraform & Ansible
1. Terraform: Provision AWS Resources
    - VPC with subnets (Public & Private)
        - Public subnets will host resources that need internet access
        - Private subnets will host Kubernetes worker nodes and RDS.
    - IAM Roles for Jenkins 
        - This role allows Jenkins to interact with AWS services like S3, EC2, and EKS.
    - IAM Role for Kubernetes
        - This role allows Kubernetes workloads to access AWS services like S3 and RDS using IRSA
    - IAM Role for Terraform
        - This role allows Terraform to provision and manage AWS resources.
    -  EC2 instances for Jenkins, SonarQube, and Kubernetes worker nodes
        - Attach security groups for each instance
        - Once the instances are provisioned, you can access them using their public IP addresses:
            - Jenkins: Access via http://<jenkins_instance_public_ip>:8080
            - SonarQube: Access via http://<sonarqube_instance_public_ip>:9000
            - Kubernetes Worker Node: SSH into the instance using the key pair specified.
    - S3 Bucket for Terraform State
        - Create an S3 bucket to store Terraform state files.
    - RDS PostgreSQL as the database backend
        -  allows you to run a PostgreSQL database in a managed environment, reducing maintenance overhead.
        - Create Security group for RDS
        - Create Parameter group for RDS
    - EKS (Elastic Kubernetes Service) Cluster for Kubernetes
        - we need IAM permissions to create EKS, VPC, and IAM roles
        - We need kubectl & AWS IAM Authenticator installed
    - Store Terraform state in S3 with state locking using DynamoDB.
        - Use DynamoDB for state locking to prevent concurrent Terraform executions.
        - To manage Terraform state remotely and prevent conflicts, we will:
            -  Store the Terraform state in an S3 bucket
            - Enable state locking using a DynamoDB table

2. Ansible: Configure Jenkins, Docker, and SonarQube
    - Jenkins Configuration
        - Install Jenkins on the EC2 instance.
        - Configure Jenkins plugins and credentials.
        - Installs Java, Docker, Git for Jenkins
    - for install docker and jenkins run main.yml playbook
    - Install SonarQube 
        - for install sonarqube run sonarqube.yml playbook
    -  Kubernetes RBAC and Ingress Controller
        - Deploy an Ingress Controller for managing external access to services.
        - Create RBAC roles and role bindings for Kubernetes
        -  Deploy an Nginx Ingress Controller on the cluster
***
# Phase 2: CI/CD Pipeline with Jenkins & Docker
- Jenkins will automate build, test, containerization, security scanning, and deployment.
- First, we need to create ECR-repo:
    - aws ecr create-repository --repository-name samy-ecr-repo --region us-east-2
1. Commit Stage:
    - The developer pushes code to the GitHub repository.
2. Build & Test Stage:
    - Jenkins automates the build and testing process.
    - Build:
        - Jenkins pulls the latest code from the repository.
        - Compiles the code 
        - Packages the application 
        - Use maven to:
            - Clean previous builds
            - Compile the source code.
            - Run unit tests.
3. Unit Testing:
    - Runs unit tests to verify individual components.
    - Fails the pipeline if any test fails.
4. Code Quality Check:
    - Integrates with SonarQube to analyze code quality.
    - Checks for code vulnerabilities.
5.  Containerization - Build & Push to Amazon ECR
    - Runs docker build to create the container image.
    - Runs docker push to upload the image to ECR.
6. Security Scanning (Trivy & Vault)
    - Uses Trivy to scan the Docker image for vulnerabilities.
    - Fetches secrets from HashiCorp Vault.
7.  Deployment - Helm & Kubernetes RBAC
    - Deploys the application to Kubernetes using Helm charts.
    - Updates kubectl configuration to connect to the AWS EKS cluster.
    - Runs helm upgrade --install to deploy the app.


    


