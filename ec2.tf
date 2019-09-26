data "aws_ami" "my_image" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "fjorg1" {
  key_name   = "fjorg1"
  public_key = "${var.ssh_key_flama}"
}

resource "aws_instance" "bastion_host" {
  ami                         = "${data.aws_ami.my_image.id}"
  instance_type               = "t2.micro"
  availability_zone           = "${var.aws_az}"
  subnet_id                   = "${aws_subnet.public_subnet.id}"
  private_ip                  = "${cidrhost(aws_subnet.public_subnet.cidr_block, 10)}"
  vpc_security_group_ids      = ["${aws_security_group.allow_ssh_to_public.id}"]
  key_name                    = "${aws_key_pair.fjorg1.key_name}"
  associate_public_ip_address = true
  user_data                   = "${file("cloud-init/bastion.conf")}"
}

resource "aws_instance" "k8s_controllers" {
  count                       = 3
  ami                         = "${data.aws_ami.my_image.id}"
  instance_type               = "t2.small"
  availability_zone           = "${var.aws_az}"
  subnet_id                   = "${aws_subnet.private_subnet.id}"
  private_ip                  = "${cidrhost(aws_subnet.private_subnet.cidr_block, 10 + count.index)}"
  vpc_security_group_ids      = ["${aws_security_group.allow_any_public_to_private.id}"]
  key_name                    = "${aws_key_pair.fjorg1.key_name}"
  associate_public_ip_address = false
  user_data                   = "${file("cloud-init/install_httpd.conf")}"
  iam_instance_profile        = "${aws_iam_instance_profile.kubernetes_master.name}"
  depends_on                  = ["aws_nat_gateway.nat_gw"]

  tags = {
    "kubernetes.io/cluster/mycluster" = "MasterNodes"
    kubespray-role                    = "kube-master"
  }
}

resource "aws_instance" "k8s_etcd" {
  count                       = 3
  ami                         = "${data.aws_ami.my_image.id}"
  instance_type               = "t2.micro"
  availability_zone           = "${var.aws_az}"
  subnet_id                   = "${aws_subnet.private_subnet.id}"
  private_ip                  = "${cidrhost(aws_subnet.private_subnet.cidr_block, 20 + count.index)}"
  vpc_security_group_ids      = ["${aws_security_group.allow_any_public_to_private.id}"]
  key_name                    = "${aws_key_pair.fjorg1.key_name}"
  associate_public_ip_address = false
  user_data                   = "${file("cloud-init/enable_ip_fw.conf")}"
  depends_on                  = ["aws_nat_gateway.nat_gw"]

  tags = {
    "kubernetes.io/cluster/mycluster" = "etcdNodes"
    kubespray-role                    = "etcd"
  }
}

resource "aws_instance" "k8s_workers" {
  count                       = 3
  ami                         = "${data.aws_ami.my_image.id}"
  instance_type               = "t2.small"
  availability_zone           = "${var.aws_az}"
  subnet_id                   = "${aws_subnet.private_subnet.id}"
  private_ip                  = "${cidrhost(aws_subnet.private_subnet.cidr_block, 30 + count.index)}"
  vpc_security_group_ids      = ["${aws_security_group.allow_any_public_to_private.id}"]
  key_name                    = "${aws_key_pair.fjorg1.key_name}"
  associate_public_ip_address = false
  user_data                   = "${file("cloud-init/enable_ip_fw.conf")}"
  iam_instance_profile        = "${aws_iam_instance_profile.kubernetes_worker.name}"
  depends_on                  = ["aws_nat_gateway.nat_gw"]

  tags = {
    "kubernetes.io/cluster/mycluster" = "WorkerNodes"
    kubespray-role                    = "kube-node"
  }
}
