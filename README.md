
# Terraform AWS VPC Web Setup

This project provisions a **complete AWS VPC environment** using Terraform — including public/private subnets, NAT gateways, a Bastion Host, a web server in a private subnet, and an Application Load Balancer to expose it to the internet.

Key Components

- **VPC** with CIDR '172.20.0.0/16'
- **4 Subnets**:
  - 2 Public (for NAT, Load Balancer, Bastion Host)
  - 2 Private (for Web Servers)
- **Internet Gateway** for public access
- **2 NAT Gateways** for private subnet outbound traffic
- **Route Tables** with correct routing for public and private subnets
- **Bastion Host** (in public subnet) for secure SSH access to private resources
- **EC2 Web Server** (in private subnet), auto-configured to serve static website content
- **Application Load Balancer** (ALB) in public subnets routing traffic to private EC2
- **Security Groups** to ensure least-privilege access
- **Key Pair Management** for secure SSH access

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) installed
- AWS CLI configured with your credentials ("aws configure")
- Public SSH keys for:
  - Bastion Host 
  - Web EC2 Instance



## Usage

```bash
# 1. Clone the repo
git clone https://github.com/AshishSingh1503/Terraform-VPC-setup.git
cd terraform-vpc-web

# 2. Initialize Terraform
terraform init

# 3. (Optional) Update your public IP in 'main.tf' (variable "my_ip")

# 4. Validate
terraform validate

# 5. Plan the deployment
terraform plan

# 6. Apply it!
terraform apply
