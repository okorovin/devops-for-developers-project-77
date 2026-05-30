#!/usr/bin/env bash
# Generate ansible/inventory.ini from terraform outputs.
set -euo pipefail

cd "$(dirname "$0")/../terraform"

{
  echo "[webservers]"
  terraform output -json vm_public_ips | python3 -c '
import json, sys
for i, ip in enumerate(json.load(sys.stdin)):
    print(f"vm-app-{i+1} ansible_host={ip}")
'
  echo
  echo "[webservers:vars]"
  echo "ansible_user=ubuntu"
  echo "ansible_ssh_private_key_file=~/.ssh/id_rsa"
} > ../ansible/inventory.ini

echo "Wrote ansible/inventory.ini"
