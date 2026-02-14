# Configure the Terraform AWS provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region # Reference the AWS region variable defined in variables.tf
}

# Create a VPC
resource "aws_vpc" "prod_vpc" {
  cidr_block = var.vpc_cidr # Define the VPC CIDR block with variable reference in variables.tf
  tags = {
    Name = "Prod-VPC"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.prod_vpc.id  # Reference the VPC ID from the created VPC

}

# Create Custom Route Table
resource "aws_route_table" "prod_route_table" {
  vpc_id = aws_vpc.prod_vpc.id  # Reference the VPC ID from the created VPC

  route {
    cidr_block = var.route_cidr # Define the Route CIDR block with variable reference in variables.tf
    gateway_id = aws_internet_gateway.gw.id # Reference the Internet Gateway ID from the created Internet Gateway
  }

  tags = {
    Name = "Prod-Route-Table"
  }
}

# Create a Subnet
resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.prod_vpc.id  # Reference the VPC ID from the created VPC
  cidr_block        = var.subnet_prefix  # Define the subnet CIDR block with variable reference in variables.tf
  availability_zone = var.aws_az   # Define the availability zone for the subnet

  tags = {
    Name = "Prod-Subnet"
  }
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subnet_1.id  # Reference the Subnet ID from the created Subnet
  route_table_id = aws_route_table.prod_route_table.id  # Reference the Route Table ID from the created Route Table
}

# Create a Security Group to allow port 22, 80, and 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.prod_vpc.id # Reference the VPC created above

  tags = {
    Name = "Allow-Web-Traffic"
  }
}

# HTTPS Ingress Rule
resource "aws_vpc_security_group_ingress_rule" "allow_https_ipv4" {
  description = "HTTPS"
  security_group_id = aws_security_group.allow_web.id # Reference the Security Group ID from the created Security Group
  cidr_ipv4         = var.https_ingress_cidr # Define the IP address that can access the web server via HTTPS
  from_port         = var.server_https_port # Define the port for HTTPS access
  ip_protocol       = var.https_protocol # Define the protocol for HTTPS access
  to_port           = var.server_https_port
}

# HTTP Ingress Rule
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  description = "HTTP"
  security_group_id = aws_security_group.allow_web.id # Reference the Security Group ID from the created Security Group
  cidr_ipv4         = var.http_ingress_cidr # Define the IP address that can access the web server via HTTP
  from_port         = var.server_http_port  # Define the port for HTTP access
  ip_protocol       = var.http_protocol # Define the protocol for HTTP access
  to_port           = var.server_http_port
}

# SSH Ingress Rule
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  description = "SSH"
  security_group_id = aws_security_group.allow_web.id # Reference the Security Group ID from the created Security Group
  cidr_ipv4         = var.ssh_ingress_cidr # Define the IP address that can access the web server via SSH
  from_port         = var.server_ssh_port  # Define the port for SSH access
  ip_protocol       = var.ssh_protocol # Define the protocol for SSH access
  to_port           = var.server_ssh_port
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_web.id # Reference the Security Group ID from the created Security Group
  cidr_ipv4         = var.egress_cidr # Define the IP address that can access the web server
  ip_protocol       = var.egress_protocol # Define the protocol for outbound traffic
}

# Create a network interface with an ip in the subnet that was created
resource "aws_network_interface" "web_server_nic" {
  subnet_id       = aws_subnet.subnet_1.id  # Reference the Subnet ID from the created Subnet
  private_ips     = [var.server_private_ip] # Assign a specific private IP address to the host within the subnet's CIDR block
  security_groups = [aws_security_group.allow_web.id] # Attach the security group created above

}

# Assign an Elastic IP to the network interface that was created
resource "aws_eip" "one" {
  domain                    = "vpc"
  network_interface         = aws_network_interface.web_server_nic.id # Reference the Network Interface ID from the created Network Interface
  associate_with_private_ip = var.server_private_ip # Reference the private IP address variable defined in variables.tf
  depends_on = [aws_internet_gateway.gw, aws_instance.web_server] # Ensure the Internet Gateway and EC2 instance are created before the Elastic IP is associated
}

# Create EC2 instance and attach the network interface to it
resource "aws_instance" "web_server" {
  ami           = var.ec2_instance_ami # Define the AMI ID for the EC2 instance with variable reference in variables.tf
  instance_type = var.ec2_instance_type # Define the instance type for the EC2 instance with variable reference in variables.tf
  availability_zone = var.aws_az # Define the availability zone for the instance
  key_name = "solid-key"
  
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web_server_nic.id # Reference the Network Interface ID from the created Network Interface  
  }

  tags = {
    Name = "Web-Server"
  }
}