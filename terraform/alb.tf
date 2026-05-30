resource "yandex_alb_target_group" "app" {
  name = "tg-app"

  dynamic "target" {
    for_each = yandex_compute_instance.vm
    content {
      subnet_id  = target.value.network_interface[0].subnet_id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_alb_backend_group" "app" {
  name = "bg-app"

  http_backend {
    name             = "backend-vms"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.app.id]

    healthcheck {
      timeout             = "1s"
      interval            = "2s"
      healthy_threshold   = 2
      unhealthy_threshold = 2
      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "app" {
  name = "router-app"
}

resource "yandex_alb_virtual_host" "app" {
  name           = "vh-app"
  http_router_id = yandex_alb_http_router.app.id
  authority      = ["*"]

  route {
    name = "route-default"
    http_route {
      http_match {
        path {
          prefix = "/"
        }
      }
      http_route_action {
        backend_group_id = yandex_alb_backend_group.app.id
        timeout          = "60s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "app" {
  name               = "alb-app"
  description        = "ALB for Hexlet project 77"
  network_id         = yandex_vpc_network.main.id
  security_group_ids = [yandex_vpc_security_group.alb.id]

  allocation_policy {
    location {
      zone_id   = var.yc_zone
      subnet_id = yandex_vpc_subnet.main_a.id
    }
  }

  listener {
    name = "listener-https"

    endpoint {
      ports = [443]
      address {
        external_ipv4_address {}
      }
    }

    tls {
      default_handler {
        certificate_ids = [yandex_cm_certificate.app.id]
        http_handler {
          http_router_id = yandex_alb_http_router.app.id
        }
      }
    }
  }
}
