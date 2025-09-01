
resource "aws_alb_target_group" "albTg" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpcDetails.id
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_alb_target_group_attachment" "tgAttach" {
  count            = 2
  target_group_arn = aws_alb_target_group.albTg.arn
  target_id        = aws_instance.web[count.index].id
  port             = 80

}

resource "aws_alb" "webAlb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = local.subnetIds
}

# Listener
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_alb.webAlb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.albTg.arn
  }
}