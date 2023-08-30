# токен облака
variable yandex_cloud_token {
  description = "yandex_cloud_token"
}

# идентификатор облака
variable yandex_cloud-id {
  description = "cloud-id"
  default     = "b1gr6v7elbdnhoqafffd"
}

# идентификатор директории
variable yandex_folder-id {
  description = "folder-id"
  default     = "b1gnik24ou783cj9tkch"
}

# идентификатор образа диска, используем Ubuntu 22.04
variable disk_image {
  description = "disk image"
  default     = "fd8n6sult0bipcm75u12"
}

# публичный ssh ключ
variable public_key {
  description = "public key"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLU08AWIPAFQ0vfXU3AxHZbyIREoxA1POpxofHkVBT2Q+daDdCKswyu2etTCa0VAHu2NVWireQqKeYkS1oDQpz4J2KC0r97UIp61MZpocRX657YqVfWBXc7m679b9kPAXhIBZ1v9vdOl+nd0KgXstSKN7FCwQxq4XCAUe/0r62qF2PmYiNbYzay1vSmmJEgae3hLHnGrO3m3CfVsY4c13qqon1YdfLkiw4NaXZoNg8tWFu06mH9k+v/iSWXZago+8KQZQUrVR0cBGvM1uR4Bc4RHB3lX1FuU5M5W/hxkmDmN51U7OdNk9x6Srl058MfkYa0UcrhRDr+Ksv36NzQY4V user@notebook"
}
