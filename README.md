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
    


