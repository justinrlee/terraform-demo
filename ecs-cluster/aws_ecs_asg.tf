
resource "aws_security_group" "launch_template_securitygroup" {
  name        = "${var.ecs_cluster_name}-securitygroup"
  description = "Security Group for ECS EC2 instances"
  vpc_id      = "${aws_vpc.armory_ecs.id}"

  # Security group rules are configured separately

  tags = {
    Name = "armory-ecs-sg"
    Owner = "Armory"
  }
}

resource "aws_security_group_rule" "launch_template_securitygroup_80" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.launch_template_securitygroup.id}"
}

resource "aws_security_group_rule" "launch_template_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = -1
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.launch_template_securitygroup.id}"
}

locals {
  armory_ecs_node_userdata = <<USERDATA
#!/bin/bash
echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config;
echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;
USERDATA
}

resource "aws_launch_template" "launch_template" {
  name          = "${var.ecs_asg_name}-launchtemplate"
  image_id      = "${var.ami}"
  instance_type = "m5.large"
  ebs_optimized = true

  key_name = "${var.ssh_key_name}"

  iam_instance_profile {
    name = "${var.ecsInstanceRole}"
  }

  # name_prefix = "${var.ecs_asg_name}-${var.ami}-"
  vpc_security_group_ids      = ["${aws_security_group.launch_template_securitygroup.id}"]
  user_data                   = "${base64encode(local.armory_ecs_node_userdata)}"
  
  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "armory-ecs-instance"
      Owner = "Armory"
    }
  }
}


resource "aws_autoscaling_group" "armory_ecs_lt" {
  desired_capacity     = "${var.instance_count}"
  # desired_capacity     = null
  # launch_configuration = "${aws_launch_configuration.launchconfig.id}"
  max_size             = 10
  min_size             = 0
  # name_prefix          = "${var.ecs_asg_name}-asg-"
  # Change in LC triggers auto-rebuild
  name                 = "${var.ecs_asg_name}"
  vpc_zone_identifier  = "${aws_subnet.armory_ecs.*.id}"
  default_cooldown     = 120
  
  lifecycle {
    create_before_destroy = true
  }

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.launch_template.id}"
        version = "$Latest"
      }

      override {
        instance_type = "${var.instance_family_1}.${var.instance_type_1}"
      }

      override {
        instance_type = "${var.instance_family_2}.${var.instance_type_1}"
      }

      override {
        instance_type = "${var.instance_family_1}.${var.instance_type_2}"
      }

      override {
        instance_type = "${var.instance_family_2}.${var.instance_type_2}"
      }

    }

  }

  tags = [
    {
      key                 = "Owner"
      value               = "Armory"
      propagate_at_launch = true
    },
    {
      key                 = "Name"
      value               = "armory-ecs-asg"
      propagate_at_launch = true
    },
  ]
}

output "asg_size" {
  value = aws_autoscaling_group.armory_ecs_lt.desired_capacity
}