# Description

This Ansible playbook deploys a Nomad + Consul cluster into an Ubuntu Server 20.04 machine and runs an Ethereum node in the Ropsten test net as a containerized nomad job (Docker). The ledger data is permanently persisted to a mounted drive.

# Usage
## 1. Configure the environment:
> Preserve the contents of the files and only change the mentioned values.

### 1.1. Enter the assignment directory:
```bash
cd assignment
```
### 1.2. Set server info and credentials in the `development` inventory:
```ini
# Example

[nomad_servers]
10.0.0.1:22

[nomad_clients]
10.0.0.1:22

[all:vars]
ansible_user=myuser
ansible_ssh_user=myuser
ansible_ssh_private_key_file=~/.ssh/id_rsa
```
### 1.3. Configure the data volume in `eth-node-vars.yml`:
```yaml
# Example

DATA_VOLUME_DEVICE_NAME: sdc
DATA_VOLUME_FILESYSTEM: ext4
DATA_VOLUME_MOUNT_POINT: /data
DATA_VOLUME_DATA_OWNER: myuser
```
### 1.4. Configure Docker Hub credentials in `eth-node-vars.yml`:
> This step can be removed with proper docker auth configuration (TODO).
```yaml
# Example

DOCKER_HUB_USERNAME: "myuser"
DOCKER_HUB_PASSWORD: "mypass"
```
## 2. Install dependencies:
```bash
ansible-galaxy install -r requirements.yml
```
## 3. Run the playbook:
```bash
ansible-playbook eth-node.yaml
```

# Nomad UI
You can access the Nomad UI via:
```
http://<server_ip>:4646/ui/jobs
```

# TODO

- [x] Setup Docker static token authentication on the node to avoid having to specify credentials.
- [x] Setup monitoring (in this config it doesn't make much sense to setup monitoring services on the same machine).
- [x] Implement better health checks for the Ethereum node.
