# Highly Available VPC with Public and Private Subnets

This Terraform configuration creates a highly available Virtual Private Cloud (VPC) on AWS, with public and private subnets, an Internet Gateway, and NAT Gateways for outbound internet access from private subnets.

## Overview

The infrastructure includes the following components:

- A VPC with a configurable CIDR block
- Public subnets in multiple Availability Zones (AZs)
- Private subnets in multiple Availability Zones (AZs)
- An Internet Gateway attached to the VPC
- A public route table with a route to the Internet Gateway
- NAT Gateways in the public subnets (one per AZ)
- Private route tables (one per AZ) with routes to the corresponding NAT Gateways
- Associations between public subnets and the public route table
- Associations between private subnets and their corresponding private route tables

## Usage

1. Configure the required variables in a `terraform.tfvars` file or pass them as command-line arguments. The required variables are:
   - `region`: The AWS region to deploy the infrastructure.
   - `cidr_block`: The CIDR block for the VPC.
   - `public_subnets`: A list of CIDR blocks for the public subnets.
   - `private_subnets`: A list of CIDR blocks for the private subnets.
   - `availability_zones`: A list of Availability Zones to use for the subnets.
   - `tags`: A map of tags to apply to the resources.

2. Initialize the Terraform working directory:
terraform init

3. Review the execution plan:
terraform plan

4. Apply the changes to create the infrastructure:
terraform apply

5. To destroy the infrastructure, run:
terraform destroy


## Outputs

The following outputs are available after applying the configuration:

- `vpc_id`: The ID of the created VPC.
- `public_subnet_ids`: A list of IDs for the public subnets.
- `private_subnet_ids`: A list of IDs for the private subnets.
- `nat_gateway_public_ips`: A list of public IP addresses for the NAT Gateways.

## Notes

- The configuration creates a NAT Gateway in each public subnet for high availability.
- Instances in public subnets have direct internet access via the Internet Gateway.
- Instances in private subnets can access the internet via the NAT Gateways in the public subnets, but they cannot be accessed directly from the internet.
- The `depends_on` blocks are used to ensure that resources are created in the correct order, reducing the likelihood of deployment failures.

Detailed code description can be viewed here:
https://smrutiranjan7674.hashnode.dev/deploying-a-highly-available-vpc-with-public-and-private-subnets
