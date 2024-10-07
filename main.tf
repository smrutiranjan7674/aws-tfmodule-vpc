# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# create vpc
resource "aws_vpc" "redo_vpc" {
  cidr_block = var.cidr_block
  tags       = var.tags
}

# create public subnets
resource "aws_subnet" "redo_public_subnets" {
  count             = length(var.public_subnets)
  cidr_block        = var.public_subnets[count.index]
  vpc_id            = aws_vpc.redo_vpc.id
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
  depends_on = [aws_vpc.redo_vpc]
}

# create private subnets
resource "aws_subnet" "redo_private_subnets" {
  count             = length(var.private_subnets)
  cidr_block        = var.private_subnets[count.index]
  vpc_id            = aws_vpc.redo_vpc.id
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
  depends_on = [aws_vpc.redo_vpc]
}

# create internet gateway
resource "aws_internet_gateway" "redo_igw" {
  vpc_id = aws_vpc.redo_vpc.id

  tags = {
    Name = "Main IGW"
  }
  depends_on = [aws_vpc.redo_vpc]
}

# create public route table
resource "aws_route_table" "redo_public_rt" {
  vpc_id = aws_vpc.redo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.redo_igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
  depends_on = [aws_internet_gateway.redo_igw]
}

# associate public subnets with public route table
resource "aws_route_table_association" "redo_public_rt_association" {
  count          = length(aws_subnet.redo_public_subnets)
  subnet_id      = aws_subnet.redo_public_subnets[count.index].id
  route_table_id = aws_route_table.redo_public_rt.id
  depends_on     = [aws_subnet.redo_public_subnets, aws_route_table.redo_public_rt]
}

# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eip" {
  count  = length(var.public_subnets)
  domain = "vpc"
  tags = {
    Name = "NAT Gateway EIP ${count.index + 1}"
  }
  depends_on = [aws_internet_gateway.redo_igw]
}

# Create NAT Gateways
resource "aws_nat_gateway" "redo_nat_gateway" {
  count         = length(var.public_subnets)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.redo_public_subnets[count.index].id

  tags = {
    Name = "NAT Gateway ${count.index + 1}"
  }
  depends_on = [aws_internet_gateway.redo_igw, aws_eip.nat_eip, aws_subnet.redo_public_subnets]
}

# create private route tables (one for each AZ)
resource "aws_route_table" "redo_private_rt" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.redo_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.redo_nat_gateway[count.index].id
  }

  tags = {
    Name = "Private Route Table ${count.index + 1}"
  }
  depends_on = [aws_nat_gateway.redo_nat_gateway]
}

# Associate private subnets with corresponding private route tables
resource "aws_route_table_association" "private_subnet_routes" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.redo_private_subnets[count.index].id
  route_table_id = aws_route_table.redo_private_rt[count.index].id
  depends_on     = [aws_subnet.redo_private_subnets, aws_route_table.redo_private_rt]
}
