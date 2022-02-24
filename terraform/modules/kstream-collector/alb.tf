resource "aws_lb" "kstream" {
    name               = "${local.alb_name}"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.alb.id]
    subnets            = split(",", var.ELB_SUBNETS)

    enable_deletion_protection = false

    tags = {
        dtap = "POC"
        application = "kstream-collector"
        stack = "${var.KSTREAM_STACK}"
    }     
}
 
resource "aws_alb_target_group" "kstream" {
    depends_on = [
        aws_lb.kstream
        , aws_lambda_permission.ClickStreamCollector
    ]

    name        = "${local.alb_tg_name}"
    target_type = "lambda"

    tags = {
        dtap = "POC"
        application = "kstream-collector"
        stack = "${var.KSTREAM_STACK}"
    }     
}

resource "aws_lb_target_group_attachment" "kstream" {
    target_group_arn = aws_alb_target_group.kstream.arn
    target_id        = aws_lambda_function.ClickStreamCollector.arn
    depends_on       = [aws_lambda_permission.ClickStreamCollector]
}

resource "aws_alb_listener" "KStreamHttpsListener" {
    load_balancer_arn = aws_lb.kstream.id
    port              = 80
    protocol          = "HTTP"

    default_action {
        type = "fixed-response"

        fixed_response {
            content_type = "application/json"
            message_body = "{\"response_code\":\"404\", \"message\": \"Resource not found.\"}"
            status_code  = "404"
        }
    }
}

resource "aws_lb_listener_rule" "KStreamListenerRule" {
    listener_arn = aws_alb_listener.KStreamHttpsListener.arn
    priority     = 1

    action {
        type             = "forward"
        target_group_arn = aws_alb_target_group.kstream.arn
    }

    condition {
        path_pattern {
            values = ["/poc-kstream/*"]
        }
    }
    condition {
        http_request_method {
            values = ["POST"]
        }
    }
    condition {
        http_header {
            http_header_name = "client_id"
            values           = ["touchwood-app"]
        }
    }
    condition {
        http_header {
            http_header_name = "Authorization"
            values           = ["Bearer *"]
        }
    }         
}

resource "aws_lb_listener_rule" "KStreamListenerOptionsRule" {
    listener_arn = aws_alb_listener.KStreamHttpsListener.arn
    priority     = 2

    action {
        type             = "forward"
        target_group_arn = aws_alb_target_group.kstream.arn
    }

    condition {
        path_pattern {
            values = ["/poc-kstream/*"]
        }
    }
    condition {
        http_request_method {
            values = ["OPTIONS"]
        }
    }
}

output "lb_dns_name" {
    description = "The DNS name of the load balancer."
    value       = aws_lb.kstream.dns_name
}
