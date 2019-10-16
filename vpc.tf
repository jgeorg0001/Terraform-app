provider "aws" {
  region = "eu-west-3"
  alias  = "Paris"
}

resource "aws_vpc" "main"{
  cidr_block     = "10.10.0.0/16"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  tags {
    Name = "myapp-vpc"
 }
}

#Public subnets
#Pub_subnet_1
resource "aws_subnet" "public_subnet_1"{
   vpc_id = "${aws_vpc.main.id}"
   cidr_block = "10.10.1.0/24"
   availability_zone = "eu-west-3-1a"
   map_public_ip_on_launch = "true"
   tags {
     Name = "${var.PROJECT_NAME}-vpc-public-subnet-1"
 }

}

#Pub_subnet_2
resource "aws_subnet" "public_subnet_2"{
   vpc_id = "${aws_vpc.main.id}"
   cidr_block = "10.10.2.0/24"
   availability_zone = "eu-west-3-1b"
   map_public_ip_on_launch = "true"
   tags {
     Name = "${var.PROJECT_NAME}-vpc-public-subnet-2"
 }

}

#Private_subnet_1
resource "aws_subnet" "private_subnet_1"{
   vpc_id = "${aws_vpc.main.id}"
   cidr_block = "10.10.3.0/24"
   availability_zone = "eu-west-3-1a"
   map_public_ip_on_launch = "true"
   tags {
     Name = "${var.PROJECT_NAME}-vpc-private-subnet-1"
 }
}

#Private_subnet_2
resource "aws_subnet" "private_subnet_2"{
   vpc_id = "${aws_vpc.main.id}"
   cidr_block = "10.10.4.0/24"
   availability_zone = "eu-west-3-1b"
   map_public_ip_on_launch = "true"
   tags {
     Name = "${var.PROJECT_NAME}-vpc-private-subnet-2"
 }
}

#Aws IGW
resource "aws_internet_gateway" "igw"{
   vpc_id = "${aws_vpc.main.id}"
   tags {
     Name = "${var.PROJECT_NAME}-vpc-internet-gateway"
 }

}

#EIP for NGW
resource "aws_eip" "nat_eip" {
   vpc   = true
   depends_on = ["aws_internet_gateway.igw"]
}

#NAT GW
resource "aws_nat_gateway" "ngw"{
   allocation_id = "${aws_eip.nat_eip.id}"
   subnet_id = "${aws_subnet.public_subnet_1.id}"
   depends_on = ["aws_internet_gateay.igw"]
   tags {
     Name = "${var.PROJECT_NAME}-vpc-NAT-gateway"}
}

#route table for public
resource "aws_route_table" "public"{
   vpc_id = "${aws_vpc.main.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_internet_gateway.igw.id}"
   }
   tags {
     Name = "${var.PROJECT_NAME}-public_route_table"}
 }

resource "aws_route_table" "private"{
   vpc_id = "${aws_vpc.main.id}"
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_nat_gateway.ngw.id}"
   }
   tags {
     Name = "${var.PROJECT_NAME}-private_route_table"}
 }

#Route table association for public subnet
resource "aws_route_table_association" "to_public_subnet_1"{
   subnet_id = "${aws_subnet.public_subnet_1.id}"
   route_table_id = "${aws_route_table.public.id}"
}


resource "aws_route_table_association" "to_public_subnet_2"{
   subnet_id = "${aws_subnet.public_subnet_2.id}"
   route_table_id = "${aws_route_table.public.id}"
}


resource "aws_route_table_association" "to_private_subnet_1"{
   subnet_id = "${aws_subnet.private_subnet_1.id}"
   route_table_id = "${aws_route_table.private.id}"
}


resource "aws_route_table_association" "to_public_subnet_1"{
   subnet_id = "${aws_subnet.private_subnet_2.id}"
   route_table_id = "${aws_route_table.private.id}"
}

