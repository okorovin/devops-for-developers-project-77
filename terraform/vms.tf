data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "vm" {
  count       = 2
  name        = "vm-app-${count.index + 1}"
  zone        = var.yc_zone
  hostname    = "vm-app-${count.index + 1}"
  description = "Application VM #${count.index + 1}"

  platform_id = "standard-v3"

  resources {
    cores         = 2
    memory        = 1
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 15
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.main_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.vm.id]
  }

  metadata = {
    user-data = file("${path.module}/templates/cloud-init.yaml")
    ssh-keys  = "ubuntu:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }
}
