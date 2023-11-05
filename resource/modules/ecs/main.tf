# https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
data "template_file" "terraform-test-userdata" {
  template = "${file("./launch_template.sh")}"
  vars = {
    env = "${var.env}"
    project_name = "${var.project_name}"
  }
}

resource "aws_launch_template" "terraform-test-ec2" {
  name_prefix   = "${var.env}-${var.project_name}-ec2"
  image_id      = "${var.ecs_instance_ami}"
  instance_type = "${var.ecs_instance_type}"
  key_name      = "${var.env}-${var.project_name}-private-ec2-key"
  vpc_security_group_ids = [var.private_ec2_sg_id]
  iam_instance_profile {
    arn= "${var.ecs_instance_role_profile_arn}"
  }
  user_data = base64encode("${data.template_file.terraform-test-userdata.rendered}")
}

resource "aws_autoscaling_group" "terraform-test-ecs-asg-group" {
  desired_capacity   = 1
  max_size           = 1
  min_size           = 0
  vpc_zone_identifier = [var.private_subnet_3_id]

  target_group_arns = ["${var.alb_grafana_arn}", "${var.alb_app_arn}"
  #  , "${var.alb_loki_arn}"
   ]

  launch_template {
    id      = aws_launch_template.terraform-test-ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

resource "aws_ecs_task_definition" "terraform-test-springboot" {
  family                   = "${var.env}-${var.project_name}-springboot"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "${var.task_definition_app_cpu}"
  memory                   = "${var.task_definition_app_memory}"
  execution_role_arn       = "${var.ecs_task_role}"
  task_role_arn            = "${var.ecs_task_role_logging}"

  container_definitions    = <<EOF
[
    {
        "name": "${var.task_definition_app_container_name}",
        "image": "${var.task_definition_app_image}",
        "cpu": 0,
        "portMappings": [
            {
                "name": "${var.task_definition_app_container_name}-${var.app_host_port}-tcp",
                "containerPort": ${var.app_container_port},
                "hostPort": ${var.app_host_port},
                "protocol": "tcp",
                "appProtocol": "http"
            }
        ],
        "essential": true,
        "environment": [
            {
                "name": "DB_HOST",
                "value": "${var.db_instance_endpoint}"
            },
            {
                "name": "DB_NAME",
                "value": "${var.rds_db_name}"
            },
            {
                "name": "DB_USERNAME",
                "value": "${var.rds_username}"
            },
            {
                "name": "DB_PASSWORD",
                "value": "${var.rds_password}"
            }
        ],
        "mountPoints": [],
        "volumesFrom": [],
        "logConfiguration": {
            "logDriver": "awsfirelens",
            "options": {
                "LabelKeys": "container_name,ecs_task_definition,source,ecs_cluster",
                "Labels": "{job=\"firelens\"}",
                "LineFormat": "key_value",
                "Name": "grafana-loki",
                "RemoveKeys": "container_id,ecs_task_arn",
                "Url": "http://loki:3100/loki/api/v1/push"
            }
        }
    },
    {
        "name": "log_router",
        "image": "${var.grafana_loki_log_router_image}",
        "cpu": 0,
        "memoryReservation": 50,
        "portMappings": [],
        "essential": true,
        "environment": [],
        "mountPoints": [],
        "volumesFrom": [],
        "user": "0",
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-create-group": "true",
                "awslogs-group": "/firelens-container/",
                "awslogs-region": "${var.region}",
                "awslogs-stream-prefix": "firelens"
            }
        },
        "firelensConfiguration": {
            "type": "fluentbit",
            "options": {
                "enable-ecs-log-metadata": "true"
            }
        }
    }
]
EOF
}

resource "aws_ecs_task_definition" "terraform-test-grafana" {
  family                   = "${var.env}-${var.project_name}-grafana"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "${var.task_definition_grafana_cpu}"
  memory                   = "${var.task_definition_grafana_memory}"
  execution_role_arn       = "${var.ecs_task_role}"
  task_role_arn            = "${var.ecs_task_role_logging}"

  container_definitions    = <<EOF
[
    {
        "name": "${var.task_definition_grafana_container_name}",
        "image": "${var.task_definition_grafana_image}",
        "cpu": 0,
        "portMappings": [
            {
                "name": "${var.task_definition_grafana_container_name}-${var.grafana_host_port}-tcp",
                "containerPort": ${var.grafana_container_port},
                "hostPort": ${var.grafana_host_port},
                "protocol": "tcp",
                "appProtocol": "http"
            }
        ],
        "essential": true,
        "mountPoints": [],
        "volumesFrom": []
    }
]
EOF
}

resource "aws_ecs_task_definition" "terraform-test-loki" {
  family                   = "${var.env}-${var.project_name}-loki"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "${var.task_definition_loki_cpu}"
  memory                   = "${var.task_definition_loki_memory}"
  execution_role_arn       = "${var.ecs_task_role}"
  task_role_arn            = "${var.ecs_task_role_logging}"

  container_definitions    = <<EOF
[
    {
        "name": "${var.task_definition_loki_container_name}",
        "image": "${var.task_definition_loki_image}",
        "cpu": 0,
        "portMappings": [
            {
                "name": "${var.task_definition_loki_container_name}-${var.loki_container_port_1}-tcp",
                "containerPort": ${var.loki_container_port_1},
                "hostPort": ${var.loki_host_port},
                "protocol": "tcp",
                "appProtocol": "http"
            },
            {
                "name": "${var.task_definition_loki_container_name}-${var.loki_container_port_2}-tcp",
                "containerPort": ${var.loki_container_port_2},
                "hostPort": 0,
                "protocol": "tcp",
                "appProtocol": "http"
            },
            {
                "name": "${var.task_definition_loki_container_name}-${var.loki_container_port_3}-tcp",
                "containerPort": ${var.loki_container_port_3},
                "hostPort": 0,
                "protocol": "tcp",
                "appProtocol": "http"
            }
        ],
        "essential": true,
        "environment": [],
        "mountPoints": [],
        "volumesFrom": []
    }
]
EOF
}

resource "aws_ecs_cluster" "terraform-test-ecs-cluster" {
  name = "${var.env}-${var.project_name}-ecs-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "terraform-test" {
  cluster_name = aws_ecs_cluster.terraform-test-ecs-cluster.name

  capacity_providers = [aws_ecs_capacity_provider.terraform-test-asg.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.terraform-test-asg.name
  }
}

resource "aws_ecs_capacity_provider" "terraform-test-asg" {
  name = aws_autoscaling_group.terraform-test-ecs-asg-group.name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.terraform-test-ecs-asg-group.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 10
    }
  }
}

resource "aws_service_discovery_http_namespace" "terraform-test-ecs-cluster" {
  name        = aws_ecs_cluster.terraform-test-ecs-cluster.name
  description = "Namespace for Service Discovery"
}

resource "aws_ecs_service" "terraform-test-loki" {
  name                               = "${var.env}-${var.project_name}-loki"
  cluster                            = aws_ecs_cluster.terraform-test-ecs-cluster.id
  task_definition                    = aws_ecs_task_definition.terraform-test-loki.arn
  desired_count                      = 1
  launch_type                        = "EC2"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.terraform-test-ecs-cluster.arn
    service {
      discovery_name = "${var.loki_dns_name}"
      port_name      = "${var.loki_dns_name}-${var.loki_host_port}-tcp"
      client_alias {
        dns_name = "${var.loki_dns_name}"
        port     = "${var.loki_host_port}"
      }
    }
  }
  depends_on = [aws_autoscaling_group.terraform-test-ecs-asg-group]
}

resource "aws_ecs_service" "terraform-test-grafana" {
  name                               = "${var.env}-${var.project_name}-grafana"
  cluster                            = aws_ecs_cluster.terraform-test-ecs-cluster.id
  task_definition                    = aws_ecs_task_definition.terraform-test-grafana.arn
  desired_count                      = 1
  launch_type                        = "EC2"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.terraform-test-ecs-cluster.arn
  }

  depends_on = [aws_ecs_service.terraform-test-loki]
}

resource "aws_ecs_service" "terraform-test-springboot" {
  name                               = "${var.env}-${var.project_name}-springboot"
  cluster                            = aws_ecs_cluster.terraform-test-ecs-cluster.id
  task_definition                    = aws_ecs_task_definition.terraform-test-springboot.arn
  desired_count                      = 1
  launch_type                        = "EC2"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.terraform-test-ecs-cluster.arn
  }

  depends_on = [aws_ecs_service.terraform-test-loki]
}