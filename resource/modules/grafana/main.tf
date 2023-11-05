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
  url = "13.3.0.1:3000"
  auth = "admin:admin"
}

# https://registry.terraform.io/providers/grafana/grafana/latest/docs/resources/contact_point
resource "grafana_contact_point" "slack_contact_point" {
    name = "slack"

    slack {
        url = "https://hooks.slack.com/services/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"
        text = <<EOT
{{ len .Alerts.Firing }} alerts are firing!

Alert summaries:
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
Firing: {{ .Labels.alertname }}
Silence: {{ .SilenceURL }}
{{ end }}
EOT
}

resource "grafana_notification_policy" "my_policy" {
    group_by = ["alertname"]
    contact_point = grafana_contact_point.slack_contact_point.name

    group_wait = "1m"
    group_interval = "1m"
    repeat_interval = "1m"

    policy {
        matcher {
            label = "type"
            match = "="
            value = "error"
        }
        group_by = ["..."]
        contact_point = grafana_contact_point.slack_contact_point.name
    }
}

resource "grafana_folder" "rule_folder" {
  title = "My Alert Rule Folder"
}

resource "grafana_rule_group" "my_alert_rule" {
  name             = "My Rule Group"
  folder_uid       = grafana_folder.rule_folder.uid
  interval_seconds = 240
  org_id           = 1
  rule {
    name           = "My Alert Rule 1"
    for            = "1m"
    condition      = "B"
    no_data_state  = "NoData"
    exec_err_state = "Alerting"
    annotations = {
      "a" = "b"
      "c" = "d"
    }
    labels = {
      "type" = "error"
    }
    is_paused = false
    data {
      ref_id     = "A"
      query_type = ""
      relative_time_range {
        from = 600
        to   = 0
      }
      datasource_uid = grafana_data_source.loki.uid
      model = jsonencode({
        hide          = false
        intervalMs    = 1000
        maxDataPoints = 43200
        refId         = "A"
      })
    }
    data {
      ref_id     = "B"
      query_type = ""
      relative_time_range {
        from = 0
        to   = 0
      }
      datasource_uid = "-100"
      model          = <<EOT
{
    "conditions": [
        {
        "evaluator": {
            "params": [
            3
            ],
            "type": "gt"
        },
        "operator": {
            "type": "and"
        },
        "query": {
            "params": [
            "A"
            ]
        },
        "reducer": {
            "params": [],
            "type": "last"
        },
        "type": "query"
        }
    ],
    "datasource": {
        "type": "__expr__",
        "uid": "-100"
    },
    "hide": false,
    "intervalMs": 1000,
    "maxDataPoints": 43200,
    "refId": "B",
    "type": "classic_conditions"
}
EOT
    }
  }
}

resource "grafana_data_source" "loki" {
  name                   = "Loki"  # 데이터 소스의 이름
  type                   = "loki"              # 데이터 소스 유형 (MySQL의 경우 "mysql")
  access_mode            = "proxy"             # 데이터 소스에 액세스하는 방법
  url                    = "http://loki:3100" # MySQL 데이터베이스의 주소
}