resource "aws_launch_template" "template-web" {
  name          = var.launch-template-web-name
  image_id      = var.image-id
  instance_type = var.instance-type

  # 인스턴스 안에서 메타데이터 사용가능
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  network_interfaces {
    device_index    = 0
    security_groups = [aws_security_group.asg-security-group-web.id]
  }

  user_data = base64encode(templatefile("web-user-data.sh", {
    server_name = "logserver.com"
  }))

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_ssm_instance_profile.arn
  }

   depends_on = [
    aws_lb.alb-web
  ]

  tag_specifications {

    resource_type = "instance"
    tags = {
      Name = var.web-instance-name
    }
  }
}