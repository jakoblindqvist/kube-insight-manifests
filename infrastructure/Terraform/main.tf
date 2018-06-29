variable "aws_access_key" {
  description = "AWS access key"
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS secret key"
  default     = ""
}

variable "aws_region" {
  description = "Region where the infrastructure is to be created. For example, 'us-east-1'. See http://docs.aws.amazon.com/general/latest/gr/rande.html#ec2_region"
  default     = "eu-west-3"
}

variable "ssh_public_key_path" {
  description = "Local file path to public SSH login key for created VMs. Default: ~/.ssh/id_rsa.pub"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ssh_private_key_path" {
  description = "Local file path to private SSH login key for created VMs. Default: ~/.ssh/id_rsa"
  default     = "kube-insight-ssh.pem"
}

variable "ssh_key_name" {
  description = "Name of the ssh key."
  default     = "kube-insight-ssh"
}

variable "ami_id" {
  description = "The AMI to use."
  default     = "ami-20ee5e5d"
}

#
# Resources
#

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

# create a key pair from public SSH key
resource "aws_key_pair" "sshkey" {
  key_name   = "${var.ssh_key_name}"
  public_key = "${file(pathexpand("${var.ssh_public_key_path}"))}"
}

resource "aws_instance" "master1" {
  ami             = "${var.ami_id}"
  instance_type   = "t2.medium"
  security_groups = ["${aws_security_group.kube-insight.name}"]

  root_block_device {
    volume_size = "40"
  }

  key_name = "${var.ssh_key_name}"

  tags {
    Name = "master1"
  }

  connection {
    type        = "ssh"
    host        = "${aws_instance.master1.public_ip}"
    user        = "ubuntu"
    agent       = false
    private_key = "${file(pathexpand("${var.ssh_private_key_path}"))}"
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "master-bootstrap.sh"
    destination = "/tmp/master-bootstrap.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/master-bootstrap.sh",
      "/tmp/master-bootstrap.sh --token=3lcnt0.lk1vmu7e1y9l8pxq --apiserver-advertise-ip=${aws_instance.master1.private_ip} --extra-cert-sans=${aws_instance.master1.public_ip}",
    ]
  }
}

# create elastic IP for master (regular public IPs do not survive restarts)
# resource "aws_eip" "master_eip" {
#   instance = "${aws_instance.master.id}"
#   vpc      = true
# }

# GlusterFS cluster for registry and block storage
# -----------------------------------------------------------

# -----------------------------------------------------------

# App nodes
# -----------------------------------------------------------
resource "aws_instance" "app1" {
  ami             = "${var.ami_id}"
  instance_type   = "t2.medium"
  security_groups = ["${aws_security_group.kube-insight.name}"]

  root_block_device {
    volume_size = "40"
  }

  key_name = "${var.ssh_key_name}"

  tags {
    Name = "app1"
  }

  connection {
    type        = "ssh"
    host        = "${aws_instance.master1.public_ip}"
    user        = "ubuntu"
    agent       = false
    private_key = "${file(pathexpand("${var.ssh_private_key_path}"))}"
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "worker-bootstrap.sh"
    destination = "/tmp/worker-bootstrap.sh"
  }
}

resource "aws_instance" "app2" {
  ami             = "${var.ami_id}"
  instance_type   = "t2.medium"
  security_groups = ["${aws_security_group.kube-insight.name}"]

  root_block_device {
    volume_size = "40"
  }

  key_name = "${var.ssh_key_name}"

  tags {
    Name = "app2"
  }

  connection {
    type        = "ssh"
    host        = "${aws_instance.master1.public_ip}"
    user        = "ubuntu"
    agent       = false
    private_key = "${file(pathexpand("${var.ssh_private_key_path}"))}"
    timeout     = "5m"
  }

  provisioner "file" {
    source      = "worker-bootstrap.sh"
    destination = "/tmp/worker-bootstrap.sh"
  }
}

# ------------------------------------------------------------

# Infrastructure nodes for logging and metrics
# -----------------------------------------------------------
# resource "aws_instance" "infra1" {
#   ami             = "${var.ami_id}"
#   instance_type   = "t2.xlarge"
#   security_groups = ["${aws_security_group.openshift_open.name}"]
#
#   root_block_device {
#     volume_size = "40"
#   }
#
#   key_name = "${var.ssh_key_name}"
#
#   tags {
#     Name = "infra1"
#   }
# }
#
# resource "aws_instance" "infra2" {
#   ami             = "${var.ami_id}"
#   instance_type   = "t2.xlarge"
#   security_groups = ["${aws_security_group.openshift_open.name}"]
#
#   root_block_device {
#     volume_size = "40"
#   }
#
#   key_name = "${var.ssh_key_name}"
#
#   tags {
#     Name = "infra2"
#   }
# }
#
# resource "aws_instance" "infra3" {
#   ami             = "${var.ami_id}"
#   instance_type   = "t2.xlarge"
#   security_groups = ["${aws_security_group.openshift_open.name}"]
#
#   root_block_device {
#     volume_size = "40"
#   }
#
#   key_name = "${var.ssh_key_name}"
#
#   tags {
#     Name = "infra3"
#   }
# }
# ---------------------------------------------------

resource "aws_security_group" "kube-insight" {
  name        = "kube-insight"
  description = "Allow all inbound traffic within the group and from uminova"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = "true"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["212.32.186.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#
# Output
#

output "master1_public_dns" {
  value = "${aws_instance.master1.public_dns}"
}

# -------------------------------------------

# --------------------------------------------
output "app1_public_dns" {
  value = "${aws_instance.app1.public_dns}"
}

output "app2_public_dns" {
  value = "${aws_instance.app2.public_dns}"
}

# --------------------------------------------
# output "infra1_public_dns" {
#   value = "${aws_instance.infra1.public_dns}"
# }
#
# output "infra2_public_dns" {
#   value = "${aws_instance.infra2.public_dns}"
# }
#
# output "infra3_public_dns" {
#   value = "${aws_instance.infra3.public_dns}"
# }

