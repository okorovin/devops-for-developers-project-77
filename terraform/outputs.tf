output "alb_external_ip" {
  description = "Public IPv4 of HTTP listener of the ALB"
  value       = yandex_alb_load_balancer.app.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "vm_public_ips" {
  description = "Public IPv4 addresses of the application VMs"
  value       = [for vm in yandex_compute_instance.vm : vm.network_interface[0].nat_ip_address]
}

output "vm_internal_ips" {
  description = "Internal IPv4 addresses of the application VMs"
  value       = [for vm in yandex_compute_instance.vm : vm.network_interface[0].ip_address]
}

output "dns_nameservers" {
  description = "Yandex Cloud DNS nameservers — set these at the domain registrar"
  value       = ["ns1.yandexcloud.net", "ns2.yandexcloud.net"]
}

output "domain" {
  description = "Public domain"
  value       = var.domain
}

output "app_url_http" {
  description = "HTTP URL"
  value       = "http://${var.domain}"
}

output "app_url_https" {
  description = "HTTPS URL"
  value       = "https://${var.domain}"
}
