# Define AWS Provider
provider "aws" {
    region = "us-east-2"
}
                                # Define VPC
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
    Name        = "samy_vpc"
    }
} 
                                # Define Subnets
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name        = "samy-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name        = "samy-private-subnet"
  }
}

#                                 # IAM Role for Jenkins
resource "aws_iam_role" "jenkins_role" {
  name = "Asamy_jenkins_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


#                                 # IAM Role for Kubernetes
# resource "aws_iam_role" "kubernetes_role" {
#   name = "Asamy_kubernetes-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "eks.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
# }

#                                 # IAM Role for Terraform
resource "aws_iam_role" "terraform_role" {
  name = "Asamy_terraform-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

                                # Create three EC2 instances for Jenkins, SonarQube, and Kubernetes worker nodes
resource "aws_key_pair" "devops_key" {
  key_name   = "devops-key"
  public_key = file("~/.ssh/id_rsa.pub") 
}

resource "aws_security_group" "devops_sg" {
  name        = "devops-security-group"
  description = "Allow SSH, HTTP, and custom ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "jenkins" {
  ami           = "ami-05803413c51f242b7"  
  instance_type = "t2.medium"
  key_name      = aws_key_pair.devops_key.key_name
  security_groups = [aws_security_group.devops_sg.name]

  tags = {
    Name = "Jenkins-Server"
  }
}

resource "aws_instance" "sonarqube" {
  ami           = "ami-05803413c51f242b7"
  instance_type = "t2.medium"
  key_name      = aws_key_pair.devops_key.key_name
  security_groups = [aws_security_group.devops_sg.name]

  tags = {
    Name = "SonarQube-Server"
  }
}

resource "aws_instance" "k8s_worker" {
  count         = 2  # Creates 2 worker nodes
  ami           = "ami-05803413c51f242b7"
  instance_type = "t2.medium"
  key_name      = aws_key_pair.devops_key.key_name
  security_groups = [aws_security_group.devops_sg.name]
}

                                # S3 bucket for Terraform state storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = "samyivolve-terraform-state-bucket"
}
  resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# terraform {
#   backend "s3" {
#     bucket         = "samy-terraform-state-bucket"
#     key            = "terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#   }
# }

                                #  Create an RDS PostgreSQL instance
 resource "aws_security_group" "rds_sg" {
  name_prefix = "rds-postgres-sg"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   
  }

  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-postgres-sg"
  }
}
resource "aws_db_parameter_group" "postgres16" {
  name        = "custom-postgres16"
  family      = "postgres16"
  description = "Custom parameter group for PostgreSQL 16"

  parameter {
    name  = "log_statement"
    value = "all"
  }
}
resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version      = "16.3" 
  instance_class       = "db.t3.micro"
  db_name              = "mydb"
  username             = "samy"
  password             = "DevAhmed24"
  parameter_group_name = aws_db_parameter_group.postgres16.name 
}

                                # EKS Cluster for Kubernetes
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_subnet" "eks_subnet_1" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "eks-subnet-1"
  }
}
resource "aws_subnet" "eks_subnet_2" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-2c"

  tags = {
    Name = "eks-subnet-2"
  }
}


resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
        aws_subnet.eks_subnet_1.id,
        aws_subnet.eks_subnet_2.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ec2_container_registry_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# resource "aws_eks_node_group" "eks_node_group" {
#   cluster_name    = aws_eks_cluster.eks_cluster.name
#   node_group_name = "my-eks-node-group"
#   node_role_arn   = aws_iam_role.eks_node_role.arn
#   subnet_ids      = [
#                         aws_subnet.eks_subnet_1.id,
#                         aws_subnet.eks_subnet_2.id
#   ]

#   scaling_config {
#     desired_size = 2
#     max_size     = 3
#     min_size     = 1
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.eks_worker_node_policy,
#     aws_iam_role_policy_attachment.eks_cni_policy,
#     aws_iam_role_policy_attachment.eks_ec2_container_registry_policy,
#   ]
# }

                                # Store Terraform state in S3 with state locking using DynamoDB.
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}