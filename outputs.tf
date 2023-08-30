output "internal_ip_address_nginx_1" {
  value = yandex_compute_instance.nginx-1.network_interface.0.ip_address
}

output "external_ip_address_nginx-1" {
  value = yandex_compute_instance.nginx-1.network_interface.0.nat_ip_address
}

output "internal_ip_address_nginx_2" {
  value = yandex_compute_instance.nginx-2.network_interface.0.ip_address
}

output "external_ip_address_nginx-2" {
  value = yandex_compute_instance.nginx-2.network_interface.0.nat_ip_address
}

output "internal_ip_address_zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.ip_address
}

output "external_ip_address_zabbix" {
  value = yandex_compute_instance.zabbix.network_interface.0.nat_ip_address
}

output "internal_ip_address_elastic" {
  value = yandex_compute_instance.elastic.network_interface.0.ip_address
}

output "external_ip_address_elastic" {
  value = yandex_compute_instance.elastic.network_interface.0.nat_ip_address
}

output "internal_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
}

output "external_ip_address_kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "external_ip_address_listener-1" {
  value = yandex_alb_load_balancer.l7-balancer.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "internal_ip_address_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
}

output "external_ip_address_bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}