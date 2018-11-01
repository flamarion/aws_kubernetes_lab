resource "aws_vpc" "kubernetes_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  instance_tenancy     = "dedicated"
}

resource "aws_subnet" "kubernetes_subnet" {
  vpc_id            = "${aws_vpc.kubernetes_vpc.id}"
  cidr_block        = "10.10.0.0/16"
  availability_zone = "${var.aws_az}"

  depends_on = ["aws_vpc.kubernetes_vpc"]
}

resource "aws_internet_gateway" "kubernetes_igw" {
  vpc_id = "${aws_vpc.kubernetes_vpc.id}"

  depends_on = ["aws_vpc.kubernetes_vpc"]
}

resource "aws_route_table" "kubernetes_rt" {
  vpc_id = "${aws_vpc.kubernetes_vpc.id}"

  route {
    gateway_id = "${aws_internet_gateway.kubernetes_igw.id}"
    cidr_block = "0.0.0.0/0"
  }

  depends_on = ["aws_vpc.kubernetes_vpc"]
}

resource "aws_route_table_association" "kubernetes_rta" {
  subnet_id      = "${aws_subnet.kubernetes_subnet.id}"
  route_table_id = "${aws_route_table.kubernetes_rt.id}"
}
