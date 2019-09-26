resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id     = "${aws_vpc.vpc.id}"
  depends_on = ["aws_vpc.vpc"]
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_az}"
  map_public_ip_on_launch = true

  depends_on = ["aws_vpc.vpc"]

  tags = {
    "kubernetes.io/role/elb" = "PublicSubnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_az}"

  depends_on = ["aws_vpc.vpc"]

  tags = {
    "kubernetes.io/cluster/mycluster" = "PrivateSubnet"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.id}"

  depends_on = ["aws_eip.nat_eip"]
}

resource "ws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    gateway_id = "${aws_internet_gateway.igw.id}"
    cidr_block = "0.0.0.0/0"
  }

  depends_on = ["aws_vpc.vpc"]
}

resource "aws_route_table" "private_rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  #route = {
  #  nat_gateway_id = "${aws_nat_gateway.nat_gw.id}"
  #  cidr_block     = "0.0.0.0/0"
  #}

  depends_on = ["aws_vpc.vpc"]

  tags = {
    "kubernetes.io/cluster/mycluster" = "PrivateRouteTable"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public_rt.id}"

  depends_on = ["aws_subnet.public_subnet"]
}

resource "aws_route_table_association" "private_rta" {
  subnet_id      = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private_rt.id}"

  depends_on = ["aws_subnet.private_subnet"]
}

resource "aws_elb" "k8s_controllers_elb" {
  name                      = "k8scontrollerselb"
  subnets                   = ["${aws_subnet.public_subnet.id}"]
  security_groups           = ["${aws_security_group.allow_k8s_elb.id}"]
  instances                 = ["${aws_instance.k8s_controllers.*.id}"]
  cross_zone_load_balancing = false

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    lb_port           = 6443
    lb_protocol       = "tcp"
    instance_port     = 6443
    instance_protocol = "tcp"
  }

  #health_check {
  #  healthy_threshold   = 2
  #  unhealthy_threshold = 2
  #  timeout             = 15
  #  target              = "HTTP:8080/healthz"
  #  interval            = 30
  #}

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/"
    interval            = 30
  }
  depends_on = ["aws_instance.k8s_controllers"]

  tags = {
    "kubernetes.io/cluster/mycluster" = "PrivateSubnet"
  }
}

resource "aws_security_group" "allow_k8s_elb" {
  name        = "allow_k8s_elb"
  description = "Allow trafic to K8S controllers"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
}

resource "aws_security_group" "allow_ssh_to_public" {
  name        = "allow_ssh_public"
  description = "Allow SSH from internet to the public subnet"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_any_public_to_private" {
  name        = "allow_ssh_public_to_private_net"
  description = "Allow any traffic from public subnet and elb to the private subnet"

  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_subnet.public_subnet.cidr_block}"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.allow_k8s_elb.id}"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
