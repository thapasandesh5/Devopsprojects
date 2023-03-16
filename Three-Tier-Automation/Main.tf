resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/21"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true
  

  tags = {
    Name = "Terraform VPC"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    name = "terragateway"
  }
  
  
}

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.0.0/24"
  

  tags = {
    "name" = "terrasubnetpublic"
  }
  
}

resource "aws_route_table" "route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "10.0.0.0/21"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "terraformroutetable"
  }
}

resource "aws_route_table_association" "subnet-route-table" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.route-table.id
  
}

resource "aws_subnet" "private-subnett" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.1.10.0/23"
 
  

  tags = {
    "name" = "terrasubnetprivate"
  }
  
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public-subnet.*.id, 0)}"
  depends_on    = [aws_internet_gateway.gateway]
  tags = {
    Name        = "nat"
  }
}

#Creates a RDS instance.

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

#Configures security group for Web layer.
resource "aws_security_group" "webserver_sg" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

tags = {
  Name = "webserver_security"
  }
}

#EC2 instances for webservers.

resource "aws_instance" "jenkins_server" {
  ami             = "ami-0cff7528ff583bf9a"
  instance_type   = "t2.micro"
  key_name = "terraform"
  subnet_id = aws_subnet.public-subnet.id

  tags = {
    Name = "Jenkins_server-terraform"
  }
}

#Application load balancer.

resource "aws_lb" "weblb" {
  name               = "webbalancer"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public-subnet.id][aws_subnet.private-subnett.id]

}
