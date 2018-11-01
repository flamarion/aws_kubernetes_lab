output "kubernetes_vpc_id" {
  value = "${aws_vpc.kubernetes_vpc.id}"
}

output "kubernets_subnet_id" {
  value = "${aws_subnet.kubernetes_subnet.id}"
}

output "kubernetes_subnet_cidr" {
  value = "${aws_subnet.kubernetes_subnet.cidr_block}"
}

output "kubernetes_igw_id" {
  value = "${aws_internet_gateway.kubernetes_igw.id}"
}
