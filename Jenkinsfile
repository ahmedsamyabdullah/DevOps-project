pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-2"
        ECR_REPO = "646304591001.dkr.ecr.us-east-2.amazonaws.com/samy-ecr-repo"
        DOCKER_IMAGE = "${ECR_REPO}:latest"
        KUBE_NAMESPACE = "default"
        KUBE_CLUSTER = "my-eks-cluster"
    }

    stages {

        stage('Commit Stage - Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/ahmedsamyabdullah/DevOps-project'
            }
        }

        stage('Build & Test') {
            steps {
                script {
                    sh 'mvn clean package'
                }
            }
        }

        stage('Code Quality - SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Containerization - Build & Push to Amazon ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}"
                    sh "docker build -t ${DOCKER_IMAGE} ."
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Security Scanning - SonarQube & HashiCorp Vault') {
            steps {
                script {
                    sh 'trivy image ${DOCKER_IMAGE} || true'
                    sh 'vault kv get secret/my-app-credentials'
                }
            }
        }

        stage('Deployment - Helm & Kubernetes RBAC') {
            steps {
                script {
                    sh "aws eks --region ${AWS_REGION} update-kubeconfig --name ${KUBE_CLUSTER}"
                    sh "helm upgrade --install my-app helm/ -n ${KUBE_NAMESPACE}"
                }
            }
        }
    }
}
