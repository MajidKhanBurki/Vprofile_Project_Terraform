resource "aws_security_group" "vprofile-bean-elb-sg" {

  name        = "vprofile-bean-elb-sg"
  description = "Security group for bean-elb"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name      = "vprofile-bean-elb"
    ManagedBy = "Terraform"
    Project   = "Vprofile"
  }
}


resource "aws_vpc_security_group_ingress_rule" "allow_http_for_elb" {
  security_group_id = aws_security_group.vprofile-bean-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv4" {
  security_group_id = aws_security_group.vprofile-bean-elb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv6" {
  security_group_id = aws_security_group.vprofile-bean-elb-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "vprofile-bastion-sg" {

  name        = "vprofile-bastion-sg"
  description = "Security group for vprofile bastion host sg"
  vpc_id      = module.vpc.vpc_id
  tags = {
    "Name"    = "Vprofile bastion host sg"
    ManagedBy = "Terraform"
    Project   = "Vprofile"
  }
}

resource "aws_vpc_security_group_ingress_rule" "sshfromMyIpforBastion" {
  security_group_id = aws_security_group.vprofile-bastion-sg.id
  cidr_ipv4         = var.MYIP
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutBoundForBastion" {
  security_group_id = aws_security_group.vprofile-bastion-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutBoundForBastionIpv6" {
  security_group_id = aws_security_group.vprofile-bastion-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = -1
}

resource "aws_security_group" "vprofile-prodbean-sg" {

  name        = "vprofile-prodbean-sg"
  description = "Security group for beanstalk instances"
  vpc_id      = module.vpc.vpc_id

  tags = {
    "Name"    = "vprofile-prodbean-sg"
    ManagedBy = "Terraform"
    Project   = "Vprofile"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_fromELB" {
  security_group_id            = aws_security_group.vprofile-bean-elb-sg.id
  referenced_security_group_id = aws_security_group.vprofile-bean-elb-sg.id
  from_port                    = 80
  ip_protocol                  = "tcp"
  to_port                      = 80

}

resource "aws_vpc_security_group_ingress_rule" "sshfromAnywhere" {
  security_group_id = aws_security_group.vprofile-prodbean-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv4forBeanInst" {
  security_group_id = aws_security_group.vprofile-prodbean-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv6forBeanInst" {
  security_group_id = aws_security_group.vprofile-prodbean-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}


resource "aws_security_group" "vprofile-backend-sg" {
  name        = "vprofile-backend-sg"
  description = "Security group for RDS, active mq, elastic cache"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name      = "vprofile-backend-sg"
    ManagedBy = "Terraform"
    Project   = "Vprofile"
  }
}
resource "aws_vpc_security_group_ingress_rule" "AllowAllFromBeanInstance" {
  security_group_id            = aws_security_group.vprofile-backend-sg.id
  referenced_security_group_id = aws_security_group.vprofile-prodbean-sg.id
  from_port                    = 0
  to_port                      = 65535
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "Allow3306FromBastionInstance" {
  security_group_id            = aws_security_group.vprofile-backend-sg.id
  referenced_security_group_id = aws_security_group.vprofile-bastion-sg.id
  from_port                    = 3306
  ip_protocol                  = "tcp"
  to_port                      = 3306
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv4forbackend" {
  security_group_id = aws_security_group.vprofile-backend-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "allowAllOutbound_ipv6forBeanBackend" {
  security_group_id = aws_security_group.vprofile-backend-sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_ingress_rule" "Backendsec_group_allow_itself" {
  security_group_id            = aws_security_group.vprofile-backend-sg.id
  referenced_security_group_id = aws_security_group.vprofile-backend-sg.id
  from_port                    = 0
  ip_protocol                  = "tcp"
  to_port                      = 65535
}