# Define the variables
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type = string
  default = "eu-west-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type = string
  default = "10.0.0.0/16"
}

variable "route_cidr" {
  description = "The CIDR block for routing traffic to the Internet Gateway"
  type = string
  default = "0.0.0.0/0"  # Default Route to route all IPv4 traffic to the Internet Gateway
}

variable "subnet_prefix" {
  description = "The CIDR block for the subnet"
  type = string
  default = "10.0.1.0/24"
}

variable "aws_az" {
  description = "The AWS availability zone to deploy resources in"
  type = string
  default = "eu-west-1a"
}

variable "https_ingress_cidr" {
  description = "The CIDR block for HTTPS ingress rules"
  type = string
  default = "0.0.0.0/0" # Allow any IP address to access the web server via HTTPS
}

variable "server_https_port" {
  description = "The HTTPS port for the web server"
  type = string
  default = "443"
}

variable "https_protocol" {
  description = "The HTTPS protocol for the web server"
  type = string
  default = "tcp"
}

variable "http_ingress_cidr" {
  description = "The CIDR block for HTTP ingress rules"
  type = string
  default = "0.0.0.0/0" # Allow any IP address to access the web server via HTTP
}

variable "server_http_port" {
  description = "The HTTP port for the web server"
  type = string
  default = "80"
}

variable "http_protocol" {
  description = "The HTTP protocol for the web server"
  type = string
  default = "tcp"
}

variable "ssh_ingress_cidr" {
  description = "The CIDR block for SSH ingress rules"
  type = string
  default = "0.0.0.0/0" # Allow any IP address to access the web server via SSH
}

variable "server_ssh_port" {
  description = "The SSH port for the web server"
  type = string
  default = "22"
}

variable "ssh_protocol" {
  description = "The SSH protocol for the web server"
  type = string
  default = "tcp"
}

variable "egress_cidr" {
  description = "The CIDR block for egress rules"
  type = string
  default = "0.0.0.0/0" # Allow any IP address to access the web server
}

variable "egress_protocol" {
  description = "The protocol for egress rules"
  type = string
  default = "-1" # Allow all ports for egress traffic
}

variable "server_private_ip" {
  description = "The private IP address of the web server"
  type = string
  default = "10.0.1.30"
}

variable "ec2_instance_ami" {
  description = "The AMI ID for the EC2 instance"
  type = string
  default = "ami-03446a3af42c5e74e" # Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
}

variable "ec2_instance_type" {
  description = "The instance type for the EC2 instance"
  type = string
  default = "t3.micro"
}