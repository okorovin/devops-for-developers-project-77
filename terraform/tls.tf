resource "yandex_cm_certificate" "app" {
  name    = "cert-${replace(var.domain, ".", "-")}"
  domains = [var.domain, "www.${var.domain}"]

  managed {
    challenge_type = "DNS_CNAME"
  }
}
