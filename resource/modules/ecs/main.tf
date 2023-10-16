data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}

resource "aws_launch_template" "dory-terraform-test-ec2" {
  name_prefix   = "${var.env}-${var.project_name}-ec2"
  image_id      = "ami-0f6996e691edaec4b"
  instance_type = "t4g.medium"
  key_name      = "${var.env}-${var.project_name}-private-ec2-key"
  vpc_security_group_ids = [aws_security_group.dory-terraform-test-private-ec2.id]
  iam_instance_profile {
    arn= "<ecsInstanceRole>"
  }
  user_data = filebase64("./launch_template.sh")
}

resource "aws_autoscaling_group" "dory-terraform-test-ecs-asg-group" {
  desired_capacity   = 1
  max_size           = 1
  min_size           = 0
  vpc_zone_identifier = [aws_subnet.dory-terraform-test-private-subnet-3.id]

  target_group_arns = [aws_alb_target_group.dory-terraform-test-alb-grafana.arn, aws_alb_target_group.dory-terraform-test-alb-app.arn, aws_alb_target_group.dory-terraform-test-alb-loki.arn]

  launch_template {
    id      = aws_launch_template.dory-terraform-test-ec2.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  depends_on = [aws_alb_target_group.dory-terraform-test-alb-grafana, aws_alb_target_group.dory-terraform-test-alb-loki, aws_alb_target_group.dory-terraform-test-alb-app]
}

resource "aws_ecs_task_definition" "dory-terraform-test-springboot" {
  family                   = "${var.env}-${var.project_name}-springboot"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = 512
  memory                   = 512
  execution_role_arn       = "<ECS_TASK_ROLE>" # for Using ECR
  task_role_arn            = "<ECS_TASK_ROLE_LOGGING>"

  container_definitions    = <<EOF
[
    {
        "name": "test-springboot",
        "image": "<스프링부트 앱 이미지 ECR 주소>",
        "cpu": 0,
        "portMappings": [
            {
                "name": "test-springboot-3033-tcp",
                "containerPort": 8080,
                "hostPort": 3033,
                "protocol": "tcp",
                "appProtocol": "http"
            }
        ],
        "essential": true,
        "environment": [],
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
        "image": "grafana/fluent-bit-plugin-loki:main-a05744a-arm64",
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
                "awslogs-region": "ap-northeast-2",
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

resource "aws_ecs_task_definition" "dory-terraform-test-grafana" {
  family                   = "${var.env}-${var.project_name}-grafana"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = 512
  memory                   = 512
  execution_role_arn       = "<ECS_TASK_ROLE>" # for Using ECR
  task_role_arn            = "<ECS_TASK_ROLE_LOGGING>"

  container_definitions    = <<EOF
[
    {
        "name": "grafana",
        "image": "<Grafana 이미지 ECR 주소>",
        "cpu": 0,
        "portMappings": [
            {
                "name": "grafana-3000-tcp",
                "containerPort": 3000,
                "hostPort": 3000,
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

resource "aws_ecs_task_definition" "dory-terraform-test-loki" {
  family                   = "${var.env}-${var.project_name}-loki"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = 512
  memory                   = 512
  execution_role_arn       = "<ECS_TASK_ROLE>" # for Using ECR
  task_role_arn            = "<ECS_TASK_ROLE_LOGGING>"

  container_definitions    = <<EOF
[
    {
        "name": "loki",
        "image": "<Loki 이미지 ECR 주소>",
        "cpu": 0,
        "portMappings": [
            {
                "name": "loki-3100-tcp",
                "containerPort": 3100,
                "hostPort": 3100,
                "protocol": "tcp",
                "appProtocol": "http"
            },
            {
                "name": "loki-7946-tcp",
                "containerPort": 7946,
                "hostPort": 0,
                "protocol": "tcp",
                "appProtocol": "http"
            },
            {
                "name": "loki-9095-tcp",
                "containerPort": 9095,
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

resource "aws_ecs_cluster" "dory-terraform-test-ecs-cluster" {
  name = "${var.env}-${var.project_name}-ecs-cluster"
}

resource "aws_ecs_cluster_capacity_providers" "dory-terraform-test" {
  cluster_name = aws_ecs_cluster.dory-terraform-test-ecs-cluster.name

  capacity_providers = [aws_ecs_capacity_provider.dory-terraform-test-asg.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.dory-terraform-test-asg.name
  }
}

resource "aws_ecs_capacity_provider" "dory-terraform-test-asg" {
  name = aws_autoscaling_group.dory-terraform-test-ecs-asg-group.name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.dory-terraform-test-ecs-asg-group.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 10
    }
  }
}

resource "aws_service_discovery_http_namespace" "dory-terraform-test-ecs-cluster" {
  name        = aws_ecs_cluster.dory-terraform-test-ecs-cluster.name
  description = "Namespace for Service Discovery"
}

resource "aws_ecs_service" "dory-terraform-test-loki" {
  name                               = "${var.env}-${var.project_name}-loki"
  cluster                            = aws_ecs_cluster.dory-terraform-test-ecs-cluster.id
  task_definition                    = aws_ecs_task_definition.dory-terraform-test-loki.arn
  desired_count                      = 1
  launch_type                        = "EC2"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.dory-terraform-test-ecs-cluster.arn
    service {
      discovery_name = "loki"
      port_name      = "loki-3100-tcp"
      client_alias {
        dns_name = "loki"
        port     = 3100
      }
    }
  }
}

resource "aws_ecs_service" "dory-terraform-test-grafana" {
  name                               = "${var.env}-${var.project_name}-grafana"
  cluster                            = aws_ecs_cluster.dory-terraform-test-ecs-cluster.id
  task_definition                    = aws_ecs_task_definition.dory-terraform-test-grafana.arn
  desired_count                      = 1
  launch_type                        = "EC2"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.dory-terraform-test-ecs-cluster.arn
  }

  depends_on = [aws_ecs_service.dory-terraform-test-loki]
}

resource "aws_ecs_service" "dory-terraform-test-springboot" {
  name                               = "${var.env}-${var.project_name}-springboot"
  cluster                            = aws_ecs_cluster.dory-terraform-test-ecs-cluster.id
  task_definition                    = aws_ecs_task_definition.dory-terraform-test-springboot.arn
  desired_count                      = 1
  launch_type                        = "EC2"
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 200

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.dory-terraform-test-ecs-cluster.arn
  }

  depends_on = [aws_ecs_service.dory-terraform-test-loki]
}