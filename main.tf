resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = var.tags
}

resource "aws_subnet" "this" {
  count             = length(var.subnets)
  cidr_block        = var.subnets[count.index]
  vpc_id            = aws_vpc.this.id
  availability_zone = var.availability_zones[count.index]
}