terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = var.yandex_cloud_token
  cloud_id  = var.yandex_cloud-id
  folder_id = var.yandex_folder-id
  zone      = "ru-central1-a"
}

# создаем вм1
resource "yandex_compute_instance" "nginx-1" {
  name                      = "nginx-1"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.disk_image
      type     = "network-ssd"
      size     = "20"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
    ip_address = "192.168.10.3"
    security_group_ids = [yandex_vpc_security_group.private-sg.id]
  }
  
  metadata = {
    user-data = file("./metadata_nginx.yaml")
  }

}

# создаем вм2
resource "yandex_compute_instance" "nginx-2" {
  name                      = "nginx-2"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.disk_image
      type     = "network-ssd"
      size     = "20"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    nat       = true
    ip_address = "192.168.20.3"
    security_group_ids = [yandex_vpc_security_group.private-sg.id]
  }
  
  metadata = {
    user-data = file("./metadata_nginx.yaml")
  }
  
}

# создаем сеть и подсети
resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.20.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

resource "yandex_vpc_subnet" "subnet-3" {
  name           = "subnet3"
  zone           = "ru-central1-c"
  v4_cidr_blocks = ["192.168.30.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

resource "yandex_vpc_subnet" "subnet-4" {
  name           = "subnet4"
  zone           = "ru-central1-c"
  v4_cidr_blocks = ["192.168.40.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

# создание таргет группы
resource "yandex_alb_target_group" "foo" {
  name           = "target-group-1"

  target {
    subnet_id    = "${yandex_vpc_subnet.subnet-1.id}"
    ip_address   = "${yandex_compute_instance.nginx-1.network_interface.0.ip_address}"
  }

  target {
    subnet_id    = "${yandex_vpc_subnet.subnet-2.id}"
    ip_address   = "${yandex_compute_instance.nginx-2.network_interface.0.ip_address}"
  }
}

# создание бэкенд группы
resource "yandex_alb_backend_group" "test-backend-group" {
  name                     = "backend-group-1"
  session_affinity {
    connection {
      source_ip = true
    }
  }

  http_backend {
    name                   = "http-backend-1"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["${yandex_alb_target_group.foo.id}"]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

# создание http роутера
resource "yandex_alb_http_router" "tf-router" {
  name          = "http-router-1"
  labels        = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name                    = "virtual-host-1"
  http_router_id          = yandex_alb_http_router.tf-router.id
  route {
    name                  = "route-1"
    http_route {
      http_route_action {
        backend_group_id  = "${yandex_alb_backend_group.test-backend-group.id}"
        timeout           = "60s"
      }
    }
  }
}    

# создание L7-балансировщика
resource "yandex_alb_load_balancer" "l7-balancer" {
  name        = "l7-balancer-1"
  network_id  = "${yandex_vpc_network.network-1.id}"
  security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.l7-balancer-sg.id]

    allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = "${yandex_vpc_subnet.subnet-1.id}" 
    }
    location {
      zone_id   = "ru-central1-b"
      subnet_id = "${yandex_vpc_subnet.subnet-2.id}" 
    }
    }

  listener {
    name = "listener-1"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = "${yandex_alb_http_router.tf-router.id}"
      }
    }
  }
}

# создаем вм3 - zabbix
resource "yandex_compute_instance" "zabbix" {
  name                      = "zabbix"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.disk_image
      type     = "network-ssd"
      size     = "20"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-4.id}"
    nat       = true
    ip_address = "192.168.40.3"
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.zabbix-sg.id]
  }
  
  metadata = {
    user-data = file("./metadata_zabbix.yaml")
  }
}

# создаем вм4 - elastic
resource "yandex_compute_instance" "elastic" {
  name                      = "elastic"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-c"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = var.disk_image
      type     = "network-ssd"
      size     = "20"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-3.id}"
    nat       = true
    ip_address = "192.168.30.3"
    security_group_ids = [yandex_vpc_security_group.private-sg.id]
  }
  
  metadata = {
    user-data = file("./metadata_elastic.yaml")
  }
}

# создаем вм5 - kibana
resource "yandex_compute_instance" "kibana" {
  name                      = "kibana"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-c"

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = var.disk_image
      type     = "network-ssd"
      size     = "20"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-4.id}"
    nat       = true
    ip_address = "192.168.40.4"
    security_group_ids = [yandex_vpc_security_group.private-sg.id, yandex_vpc_security_group.kibana-sg.id]
  }
  
  metadata = {
    user-data = file("./metadata_kibana.yaml")
  }

}

# создаем группы безопасности
resource "yandex_vpc_security_group" "private-sg" {
  name        = "private-sg"
  description = "private-sg"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol       = "ANY"
    description    = "private-sg"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24", "192.168.30.0/24", "192.168.40.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "private-sg"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "yandex_vpc_security_group" "zabbix-sg" {
  name        = "zabbix-sg"
  description = "zabbix-sg"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol       = "TCP"
    description    = "zabbix agent"
    v4_cidr_blocks = ["192.168.10.0/24", "192.168.20.0/24"]
    port           = 10050
  }

  ingress {
    protocol       = "TCP"
    description    = "http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  egress {
    protocol       = "ANY"
    description    = "zabbix-sg"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "TCP"
    description       = "ssh"
    security_group_id = yandex_vpc_security_group.bastion-sg.id
    port              = 22
  }
  
}

resource "yandex_vpc_security_group" "kibana-sg" {
  name        = "kibana-sg"
  description = "kibana-sg"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol       = "TCP"
    description    = "elastic"
    v4_cidr_blocks = ["192.168.30.0/24"]
    port           = 9200
  }

  ingress {
    protocol       = "TCP"
    description    = "http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 5601
  }

  egress {
    protocol       = "ANY"
    description    = "kibana-sg"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol          = "TCP"
    description       = "ssh"
    security_group_id = yandex_vpc_security_group.bastion-sg.id
    port              = 22
  }

}

resource "yandex_vpc_security_group" "l7-balancer-sg" {
  name        = "l7-balancer-sg"
  description = "l7-balancer-sg"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol       = "TCP"
    description    = "http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  egress {
    protocol       = "ANY"
    description    = "l7-balancer-sg"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "ANY"
    description    = "l7-balancer-sg"
    v4_cidr_blocks = ["0.0.0.0/0"]
    predefined_target = "loadbalancer_healthchecks"
  }

}

# создаем бастионный хост
resource "yandex_compute_instance" "bastion" {
  name                      = "bastion"
  allow_stopping_for_update = true
  platform_id               = "standard-v3"
  zone                      = "ru-central1-c"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.disk_image
      type     = "network-ssd"
      size     = "20"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-4.id}"
    nat       = true
    ip_address = "192.168.40.5"
    security_group_ids = [yandex_vpc_security_group.bastion-sg.id]
  }

  metadata = {
    user-data = file("./metadata_bastion.yaml")
  }
  
# создаем файл hosts для ansible
  provisioner "local-exec" {
    command = <<EOT
    echo [defaults] > ansible.cfg
    echo inventory = hosts >> ansible.cfg
    echo [bastion] > hosts
    echo ${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} >> hosts
    echo -en '\n' >> hosts
    echo [nginx-1] >> hosts
    echo ${yandex_compute_instance.nginx-1.network_interface.0.ip_address} >> hosts
    echo -en '\n' >> hosts
    echo [nginx-2] >> hosts
    echo ${yandex_compute_instance.nginx-2.network_interface.0.ip_address} >> hosts
    echo -en '\n' >> hosts
    echo [elastic] >> hosts
    echo ${yandex_compute_instance.elastic.network_interface.0.ip_address} >> hosts
    echo -en '\n' >> hosts
    echo [zabbix] >> hosts
    echo ${yandex_compute_instance.zabbix.network_interface.0.ip_address} >> hosts
    echo -en '\n' >> hosts
    echo [kibana] >> hosts
    echo ${yandex_compute_instance.kibana.network_interface.0.ip_address} >> hosts
    echo -en '\n' >> hosts
    echo [local:children] >> hosts
    echo nginx-1 >> hosts
    echo nginx-2 >> hosts
    echo elastic >> hosts
    echo zabbix >> hosts
    echo kibana >> hosts
    echo -en '\n' >> hosts
    echo [local:vars] >> hosts
    echo "ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q user@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address}"'" >> hosts
    EOT
  }

}

# создаем группу безопасности бастиона
resource "yandex_vpc_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "bastion-sg"
  network_id  = "${yandex_vpc_network.network-1.id}"

  ingress {
    protocol       = "TCP"
    description    = "http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  egress {
    protocol       = "ANY"
    description    = "bastion-sg"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
  
}

# создадим снапшоты дисков
resource "yandex_compute_snapshot" "nginx-1" {
  name           = "nginx-1"
  source_disk_id = "${yandex_compute_instance.nginx-1.boot_disk.0.disk_id}"
}

resource "yandex_compute_snapshot" "nginx-2" {
  name           = "nginx-2"
  source_disk_id = "${yandex_compute_instance.nginx-2.boot_disk.0.disk_id}"
}

resource "yandex_compute_snapshot" "elastic" {
  name           = "elastic"
  source_disk_id = "${yandex_compute_instance.elastic.boot_disk.0.disk_id}"
}

resource "yandex_compute_snapshot" "kibana" {
  name           = "kibana"
  source_disk_id = "${yandex_compute_instance.kibana.boot_disk.0.disk_id}"
}

resource "yandex_compute_snapshot" "zabbix" {
  name           = "zabbix"
  source_disk_id = "${yandex_compute_instance.zabbix.boot_disk.0.disk_id}"
}

resource "yandex_compute_snapshot" "bastion" {
  name           = "bastion"
  source_disk_id = "${yandex_compute_instance.bastion.boot_disk.0.disk_id}"
}

# настраиваем расписание создания снапшотов
resource "yandex_compute_snapshot_schedule" "week" {
  name = "week"

  schedule_policy {
    # создаем снимки каждый день в полночь
    expression = "0 0 ? * *"
  }

  snapshot_count = 5

  snapshot_spec {
    description = "snapshot-description"
  }

  disk_ids = ["${yandex_compute_instance.nginx-1.boot_disk.0.disk_id}", "${yandex_compute_instance.nginx-2.boot_disk.0.disk_id}", "${yandex_compute_instance.elastic.boot_disk.0.disk_id}", "${yandex_compute_instance.kibana.boot_disk.0.disk_id}", "${yandex_compute_instance.zabbix.boot_disk.0.disk_id}", "${yandex_compute_instance.bastion.boot_disk.0.disk_id}"]

}