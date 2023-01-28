# get all availability zones in current region
#
data "aws_availability_zones" "available" {
  state = "available"
}


# vpc creation
# 
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = var.app_name
  }
}


# create route table for vpc 
#
resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-rt"
  }
}

# internet gateway is made for internet access within the vpc
#
resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.app_name}-ig"
  }
}

resource "aws_route" "main_gw_route" {
  route_table_id         = aws_route_table.main_rt.id
  gateway_id             = aws_internet_gateway.main_gw.id
  destination_cidr_block = "0.0.0.0/0"
}

# create a subnet for every availability zone in the current region 
# cidr block is 10.0.x.0/24
# name is the availability zone 
#
resource "aws_subnet" "main" {
  count             = length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = data.aws_availability_zones.available.names[count.index]
  }
}



resource "aws_route_table_association" "main" {
  count          = length(aws_subnet.main)
  subnet_id      = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.main_rt.id
}