#cloud-config
write_files:
  - encoding: b64
    content: ${service_lib}
    path: /tmp/.service_lib
