resource "aws_security_group" "alb" {
    name   = "${local.alb_security_group}"
    description = "Allow http on port 80"
    vpc_id = var.VPC_ID

    ingress {
        protocol         = "tcp"
        from_port        = 80
        to_port          = 80
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        protocol         = "-1"
        from_port        = 0
        to_port          = 0
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        dtap = "POC"
        application = "kstream-collector"
        stack = "${var.KSTREAM_STACK}"
    }  
}