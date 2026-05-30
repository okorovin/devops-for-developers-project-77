variable "yc_token" {
  description = "Yandex Cloud OAuth token"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "yc_zone" {
  description = "Default availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "domain" {
  description = "Public domain delegated to Yandex Cloud DNS"
  type        = string
  default     = "gosha.exchange"
}

variable "ssh_public_key" {
  description = "Public SSH key to authorise on VMs"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDaLeFNSIHX9d8eDdWxrdpv5FRU0ie76jt5ac6LmQvuF+8/c/vVHKXhIPyZtNeCccTVb1sB7mVYvLvIud/Q1dVpwnDcjFrX1f4daLyz5Wu3lfmQB3FaSXrB518vSsPD9vtX5MSw2Hpva8Q4QepGXxZjF3zIf0exI/hAGT/cLFArEVqw4Fm4/O1SsjHl4IA2Ha83QNVOMuqzknRwKPBUX6yI6AK0XvNhqV5fz42DafRWpXHVxXeD7OMgZg6ve2UME1qrtG2Dq5wcDNXq0gtAOik+sBLmhpbHMxGUD4983yj2NK0ao3mwxn8s5B/1YFMre3b9TCRuWG74U+Ie4yiR2xJ3P0JMbj2/gq6CzenZJmnAlvDQ+f4DTgRl01JdFXv+uNrR7gNU5hutFmO39HoHRvAepIDZgbV/jiekLIUGPD6hLLnhApK72ZhP3FlWeOqwh1gcp+laEmEZCNXG/S7+9Ica7huZRJDK6woc1zfBOOxIvibxcTL2yuoNau255S9Or4AYmu8VnIWzWVUr7/jD/CgJiPPoNaS6dotvhVCUFS9ZuZdCOCU1K5Ikwka2OGLyCUqn7cIrpKIJUa0SPvX0anyonR3q/DahdS4p2432H+7uvxih/OXrtTBYNV5uGrLJFt3IjE/ZezwNRQG/Wtiz0hxtcpoyD4KzqwJWwTHX5zs71w== okorovin@ecom.tech"
}

variable "project_name" {
  description = "Tag used in resource names"
  type        = string
  default     = "hexlet-77"
}

variable "datadog_api_key" {
  description = "DataDog API key (for sending metrics and authenticating provider)"
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "DataDog Application key (for managing resources through API)"
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "DataDog site (datadoghq.com, datadoghq.eu, etc.)"
  type        = string
  default     = "datadoghq.eu"
}
