# Define AWS Provider
provider "aws" {
    region = "us-east-2"
}
# Define VPC
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
} 
# Define Subnets
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}
