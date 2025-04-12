locals {
  name = "odo01"

}
# Creating RSA private key
resource "tls_private_key" "key" {
    algorithm = "RSA"
    rsa_bits = 4096
 }
 # Creating private key locally
 resource "local_file" "key" {
    content = tls_private_key.key.private_key_pem
    filename = "odo01-key"
    file_permission = "600"
 }
  #Create and register the public key in aws
 resource "aws_key_pair" "key" {
   key_name = "odo01-pub-key"
   public_key = tls_private_key.key.public_key_openssh
 }
# Creating Maven Security Groups
resource "aws_security_group" "maven_sg" {
    name = "maven-sg"
  description = "Allow TLS imbound traffic and all outbound traffic"

  ingress {
    description = "ssh from vpc"
    from_port = var.sshport
    to_port   = var.sshport
    protocol = "tcp"
    cidr_blocks = [var.allcidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allcidr]
  }
  tags = {
    Name = "${local.name}-maven-sg"
  }
}

# Creating Maven Server
resource "aws_instance" "maven_server" {
    ami = var.redhat
    instance_type = "t2.medium"
    key_name = aws_key_pair.key.id
    vpc_security_group_ids = [aws_security_group.maven_sg.id]
    associate_public_ip_address = true
    user_data = file("./userdata-maven.sh")
    
    tags = {
        Name = "${local.name}-maven-server"
    }
  } 
  # Creating Maven Prod Security Groups
resource "aws_security_group" "prod_sg" {
    name = "prod-sg"
  description = "Allow TLS imbound traffic and all outbound traffic"

  ingress {
    description = "ssh"
    from_port = var.sshport
    to_port   = var.sshport
    protocol = "tcp"
    cidr_blocks = [var.allcidr]
  }

ingress {
    description = "java"
    from_port = var.javaport
    to_port   = var.javaport
    protocol = "tcp"
    cidr_blocks = [var.allcidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allcidr]
  }
  tags = {
     Name = "${local.name}-prod-sg"
  }
}

# Creating Production Server
resource "aws_instance" "prod_server" {
    ami = var.redhat
    instance_type = "t2.medium"
    key_name = aws_key_pair.key.id
    vpc_security_group_ids = [aws_security_group.prod_sg.id]
    associate_public_ip_address = true
    user_data = file("./userdata-prod.sh")
    
    tags = {
        Name = "${local.name}-prod-server"
    }
  } 
