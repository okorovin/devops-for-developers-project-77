resource "yandex_dns_zone" "main" {
  name        = replace(var.domain, ".", "-") # gosha-exchange
  description = "Public DNS zone for ${var.domain}"
  zone        = "${var.domain}."
  public      = true
}

resource "yandex_dns_recordset" "apex_a" {
  zone_id = yandex_dns_zone.main.id
  name    = "${var.domain}."
  type    = "A"
  ttl     = 300
  data    = [yandex_alb_load_balancer.app.listener[0].endpoint[0].address[0].external_ipv4_address[0].address]
}

resource "yandex_dns_recordset" "www_a" {
  zone_id = yandex_dns_zone.main.id
  name    = "www.${var.domain}."
  type    = "A"
  ttl     = 300
  data    = [yandex_alb_load_balancer.app.listener[0].endpoint[0].address[0].external_ipv4_address[0].address]
}

# ACME-challenge CNAMEs (computed from cm_certificate)

resource "yandex_dns_recordset" "acme_apex" {
  zone_id = yandex_dns_zone.main.id
  name    = "${yandex_cm_certificate.app.challenges[0].dns_name}"
  type    = yandex_cm_certificate.app.challenges[0].dns_type
  ttl     = 60
  data    = [yandex_cm_certificate.app.challenges[0].dns_value]
}

resource "yandex_dns_recordset" "acme_www" {
  zone_id = yandex_dns_zone.main.id
  name    = "${yandex_cm_certificate.app.challenges[1].dns_name}"
  type    = yandex_cm_certificate.app.challenges[1].dns_type
  ttl     = 60
  data    = [yandex_cm_certificate.app.challenges[1].dns_value]
}
