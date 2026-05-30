resource "yandex_vpc_network" "main" {
  name        = "${var.project_name}-network"
  description = "VPC for Hexlet project 77"
}

resource "yandex_vpc_subnet" "main_a" {
  name           = "${var.project_name}-subnet-a"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.20.1.0/24"]
}

# ───────────── Security groups ─────────────

resource "yandex_vpc_security_group" "alb" {
  name        = "sg-alb"
  description = "Security group for Application Load Balancer"
  network_id  = yandex_vpc_network.main.id

  egress {
    description    = "All outbound"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    description    = "HTTP"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    description    = "HTTPS"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    description    = "ALB healthcheck endpoint"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 30080
  }
}

resource "yandex_vpc_security_group" "vm" {
  name        = "sg-vm"
  description = "Security group for application VMs"
  network_id  = yandex_vpc_network.main.id

  egress {
    description    = "All outbound"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 0
    to_port        = 65535
  }

  ingress {
    description    = "SSH"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    description       = "App from ALB"
    protocol          = "TCP"
    security_group_id = yandex_vpc_security_group.alb.id
    port              = 80
  }

  ingress {
    description    = "ALB healthcheck"
    protocol       = "TCP"
    predefined_target = "loadbalancer_healthchecks"
    port           = 80
  }

  ingress {
    description    = "ICMP ping"
    protocol       = "ICMP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
