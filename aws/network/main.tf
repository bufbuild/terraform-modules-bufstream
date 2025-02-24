locals {
  vpc_id           = var.create_vpc ? aws_vpc.bufstream_vpc[0].id : var.vpc_id
  azs              = slice(data.aws_availability_zones.available.names, 0, 3)
  subnet_cidrs     = cidrsubnets(var.vpc_cidr, 5, 5, 5, 5, 5, 5)
  private_az_cidrs = zipmap(local.azs, slice(local.subnet_cidrs, 0, length(local.azs)))
  public_az_cidr   = zipmap(local.azs, slice(local.subnet_cidrs, length(local.azs), length(local.azs) * 2))
  s3_endpoint      = var.s3_vpc_endpoint != null ? var.s3_vpc_endpoint : "com.amazonaws.${data.aws_region.this.name}.s3"
}

data "aws_region" "this" {}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "bufstream_vpc" {
  count      = var.create_vpc ? 1 : 0
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "bufstream" {
  count  = var.create_igw ? 1 : 0
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_eip" "nat" {
  for_each   = var.create_subnets && var.create_igw ? local.public_az_cidr : {}
  domain     = "vpc"
  depends_on = [aws_internet_gateway.bufstream]

  tags = {
    Name = "${var.vpc_name}-${each.key}-natgw"
  }
}

resource "aws_nat_gateway" "bufstream" {
  for_each      = var.create_subnets ? local.public_az_cidr : {}
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  depends_on    = [aws_internet_gateway.bufstream]

  tags = {
    Name = "${var.vpc_name}-${each.key}"
  }
}

# Subnets
resource "aws_subnet" "private" {
  for_each          = var.create_subnets ? local.private_az_cidrs : {}
  vpc_id            = aws_vpc.bufstream_vpc[0].id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name                              = "${var.vpc_name}-${each.key}-${each.value}-private"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "public" {
  for_each          = var.create_subnets ? local.public_az_cidr : {}
  vpc_id            = aws_vpc.bufstream_vpc[0].id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name                     = "${var.vpc_name}-${each.key}-${each.value}-public"
    "kubernetes.io/role/elb" = 1
  }
}

# routes
resource "aws_route_table" "public_route_table" {
  count  = var.create_subnets ? 1 : 0
  vpc_id = local.vpc_id

  tags = {
    Name = "${var.vpc_name}-public"
  }
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.create_igw ? 1 : 0
  route_table_id         = aws_route_table.public_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.bufstream[0].id
}

resource "aws_route_table_association" "routes" {
  for_each       = var.create_subnets ? aws_subnet.public : {}
  route_table_id = aws_route_table.public_route_table[0].id
  subnet_id      = each.value.id
}

resource "aws_route_table" "private_route_tables" {
  for_each = var.create_subnets ? local.private_az_cidrs : {}
  vpc_id   = aws_vpc.bufstream_vpc[0].id

  tags = {
    "Name" : "${var.vpc_name}-${each.value}-private"
  }
}

resource "aws_route" "private_routes" {
  for_each               = var.create_subnets ? local.private_az_cidrs : {}
  route_table_id         = aws_route_table.private_route_tables[each.key].id
  nat_gateway_id         = aws_nat_gateway.bufstream[each.key].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_route_table_associations" {
  for_each       = var.create_subnets ? local.private_az_cidrs : {}
  route_table_id = aws_route_table.private_route_tables[each.key].id
  subnet_id      = aws_subnet.private[each.key].id
}

# S3 endpoint
resource "aws_vpc_endpoint" "s3" {
  count        = var.create_s3_endpoint ? 1 : 0
  vpc_id       = local.vpc_id
  service_name = local.s3_endpoint
}

resource "aws_vpc_endpoint_route_table_association" "s3" {
  for_each        = var.create_s3_endpoint ? local.private_az_cidrs : {}
  route_table_id  = aws_route_table.private_route_tables[each.key].id
  vpc_endpoint_id = aws_vpc_endpoint.s3[0].id
}
