[cps]
cp1  ansible_host=${cp_ip} ansible_user=${user} ansible_ssh_private_key_file=${ssh_private_key}

[workers]
worker1 ansible_host=${worker_ip} ansible_user=${user} ansible_ssh_private_key_file=${ssh_private_key}
