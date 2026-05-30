resource "datadog_monitor" "app_http_check" {
  name    = "[${var.project_name}] App HTTP check is failing"
  type    = "service check"
  message = <<-EOT
    App HTTP check is failing on host {{host.name}}.

    The agent's `http_check` integration could not get a 2xx response from the local application endpoint.
    Likely causes: container not running, nginx hung, port not listening.

    Investigate on the host or via balancer at https://${var.domain}/
  EOT

  query = "\"http.can_connect\".over(\"instance:app-local\").by(\"host\",\"instance\").last(2).count_by_status()"

  monitor_thresholds {
    warning  = 1
    critical = 2
    ok       = 1
  }

  notify_no_data    = true
  no_data_timeframe = 10
  renotify_interval = 60

  tags = [
    "project:${var.project_name}",
    "service:app",
    "env:production",
  ]
}
