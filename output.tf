output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "igw_id" {
  value = "${aws_internet_gateway.igw.id}"
}

output "eip_public_ip" {
  value = "${aws_eip.nat_eip.public_ip}"
}

output "public_subnet_id" {
  value = "${aws_subnet.public_subnet.id}"
}

output "public_subnet_cidr_block" {
  value = "${aws_subnet.public_subnet.cidr_block}"
}

output "private_subnet_id" {
  value = "${aws_subnet.private_subnet.id}"
}

output "private_subnet_cidr_block" {
  value = "${aws_subnet.private_subnet.cidr_block}"
}

output "nat_gw_public_ip" {
  value = "${aws_nat_gateway.nat_gw.public_ip}"
}

output "nat_gw_private_ip" {
  value = "${aws_nat_gateway.nat_gw.private_ip}"
}

output "public_rt" {
  value = "${aws_route_table.public_rt.id}"
}

output "private_rt" {
  value = "${aws_route_table.private_rt.id}"
}

output "bastion_host_public_ip" {
  value = "${aws_instance.bastion_host.public_ip}"
}

output "bastion_host_public_dns" {
  value = "${aws_instance.bastion_host.public_dns}"
}

output "bastion_host_private_ip" {
  value = "${aws_instance.bastion_host.private_ip}"
}

output "bastion_host_private_dns" {
  value = "${aws_instance.bastion_host.private_dns}"
}

output "k8s_controller_private_ip" {
  value = "${aws_instance.k8s_controllers.*.private_ip}"
}

output "k8s_controller_private_dns" {
  value = "${aws_instance.k8s_controllers.*.private_dns}"
}

output "k8s_workers_private_ip" {
  value = "${aws_instance.k8s_workers.*.private_ip}"
}

output "k8s_workers_private_dns" {
  value = "${aws_instance.k8s_workers.*.private_dns}"
}

output "k8s_etcd_private_ip" {
  value = "${aws_instance.k8s_etcd.*.private_ip}"
}

output "k8s_etcd_private_dns" {
  value = "${aws_instance.k8s_etcd.*.private_dns}"
}

output "k8s_elb_dns" {
  value = "${aws_elb.k8s_controllers_elb.dns_name}"
}
