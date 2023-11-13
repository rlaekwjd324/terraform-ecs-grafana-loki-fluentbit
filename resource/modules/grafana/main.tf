terraform {
  required_version = "~> 1.5.6"

  required_providers {
    grafana = {
      source = "grafana/grafana"
      version = ">= 1.28.2"
    }
  }
}

provider "grafana" {
  url = "http://15.164.174.66:3000/"
  auth = "admin:admin"
}

# https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point
resource "grafana_contact_point" "my_contact_point" {
  name = "My Contact Point"

  email {
    addresses               = ["one@company.org", "two@company.org"]
    message                 = "{{ len .Alerts.Firing }} firing."
    subject                 = "{{ template \"default.title\" .}}"
    single_email            = true
    disable_resolve_message = false
  }
}

resource "grafana_contact_point" "slack_contact_point" {
    name = "slack"

    slack {
        url = "https://hooks.slack.com/services/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"
        username = "ERROR"
        mention_channel = "here"
        disable_resolve_message = true
        title = "에러가 발생했습니다."
        text = <<EOT
에러 발생 : {{ len .Alerts.Firing }}회

{{ range .Alerts.Firing }}
{{ template "Alert Instance Template" . }}
{{ end }}
EOT
    }
}

resource "grafana_message_template" "my_alert_template" {
    name = "Alert Instance Template"

    template = <<EOT
{{ define "Alert Instance Template" }}
{{ .Labels.alertname }}
발생 컨테이너 : {{ .Labels.container_name }}
에러 메시지 : {{ .Labels.log }}
{{ end }}
EOT
}

resource "grafana_notification_policy" "my_policy" {
    group_by = []
    contact_point = grafana_contact_point.my_contact_point.name

    group_wait = "1m"
    group_interval = "1m"
    repeat_interval = "1m"

    policy {
        matcher {
          label = "job"
          match = "="
          value = "firelens"
        }
        group_by = ["..."]
        contact_point = grafana_contact_point.slack_contact_point.name
    }
}

# 수동으로 alert rule 만들어서 그 내용과 비교하면서 값 채워나가기
resource "grafana_rule_group" "my_alert_rule" {
  name             = "My Rule Group"
  folder_uid       = grafana_folder.data_source_dashboards.uid
  interval_seconds = 60
  org_id           = 1
  rule {
    name           = "My Alert Rule 1"
    for            = "1m"
    condition      = "C"
    no_data_state  = "OK"
    exec_err_state = "OK"
    annotations = {
    }
    labels = {
    }
    is_paused = false
    data {
      ref_id     = "A"
      query_type = "range"
      datasource_uid = grafana_data_source.loki.uid
      relative_time_range {
        from = 60
        to   = 0
      }
      model = jsonencode({
        editorMode = "code"
        expr = "count_over_time({ecs_task_definition=\"dev-terraform-springboot:19\"}|log=~`.+ERROR.+`[1m])"
        hide          = false
        intervalMs    = 60000
        maxDataPoints = 43200
        refId         = "A"
        query_type = "range"
      })
    }
    data {
      ref_id     = "B"
      query_type = ""
      relative_time_range {
        from = 60
        to   = 0
      }
      datasource_uid = "__expr__"
      model          = <<EOT
{
    "conditions": [
        {
        "evaluator": {
            "params": [
            0,0
            ],
            "type": "gt"
        },
        "operator": {
            "type": "and"
        },
        "query": {
            "params": []
        },
        "reducer": {
            "params": [],
            "type": "avg"
        },
        "type": "query"
      }
    ],
    "datasource": {
        "type": "__expr__",
        "uid": "__expr__",
        "name": "Expression"
    },
    "expression": "A",
    "intervalMs": 1000,
    "maxDataPoints": 43200,
    "refId": "B",
    "type": "reduce",
    "reducer": "last"
}
EOT
    }
    data {
      ref_id     = "C"
      query_type = ""
      relative_time_range {
        from = 60
        to   = 0
      }
      datasource_uid = "__expr__"
      model          = <<EOT
{
    "conditions": [
        {
        "evaluator": {
            "params": [
            0,0
            ],
            "type": "gt"
        },
        "operator": {
            "type": "and"
        },
        "query": {
            "params": []
        },
        "reducer": {
            "params": [],
            "type": "avg"
        },
        "type": "query"
      }
    ],
    "datasource": {
        "type": "__expr__",
        "uid": "__expr__",
        "name": "Expression"
    },
    "expression": "B",
    "intervalMs": 1000,
    "maxDataPoints": 43200,
    "refId": "C",
    "type": "threshold"
}
EOT
    }
  }
  depends_on = [
    grafana_dashboard.loki
  ]
}

resource "grafana_folder" "data_source_dashboards" {
  title = "test folder data_source_dashboards"
}

resource "grafana_data_source" "loki" {
  name                   = "Loki1"  # 데이터 소스의 이름
  type                   = "loki"              # 데이터 소스 유형 (MySQL의 경우 "mysql")
  access_mode            = "proxy"             # 데이터 소스에 액세스하는 방법
  url                    = "http://loki:3100" # MySQL 데이터베이스의 주소
}

resource "grafana_dashboard" "loki" {
  folder = grafana_folder.data_source_dashboards.id
  config_json = jsonencode({
    "editable": true,
    "uid": "test-ds-dashboard-uid"
    "panels": [
      {
        "type": "timeseries",
        "title": "My Panel",
        "datasource": "${grafana_data_source.loki.name}",
        "targets": [
          {
            "refId": "A",
            "queryType": "range",
            "expr": "count_over_time({ecs_task_definition=\"dev-terraform-springboot:19\"}|log=~`.+ERROR.+`[1m])",
            "alias": "My Metric"
          }
        ]
      }
    ],
    "time": {
      "from": "now-6h",
      "to": "now"
    },
    "title": "My Dashboard test"  # 대시보드의 이름은 여기에 정의합니다.
  })
  depends_on = [
    grafana_data_source.loki
  ]
}

data "grafana_dashboard" "from_id" {
  dashboard_id = grafana_dashboard.loki.dashboard_id
}

data "grafana_dashboard" "from_uid" {
  depends_on = [
    grafana_dashboard.loki
  ]
  uid = "test-ds-dashboard-uid"
}