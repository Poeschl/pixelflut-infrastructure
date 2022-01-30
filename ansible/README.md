# Ansible Installer

When you are reading this your might be right before installing the Pixelflut infrastructure via ansible.

Before doing that, make sure the correct configuration is set in the `.env` file on the project root.

## Requirements

To use this playbook external roles and modules are required. Install them with:

```shell
ansible-galaxy install geerlingguy.docker geerlingguy.pip
ansible-galaxy collection install community.docker
````

## Install

The given Ansible playbooks will work on any apt-base linux system and also updates all installed packages as default.
After that it will install docker and docker-compose (the docker service will be restarted if existing) as well as 
transfering all needed files to the corresponding hosts.
For installing it will sudo the remote user, the password for this will be asked before starting the playbook.

It can also be used to transfer changes in your local folder.
For that just execute the playbook again and your changes on the local config or docker-compose file will be transfered.
There are two playbooks, one for the Pixelflut-Host and the second for the monitoring host.

To disable the automatic package upgrade and/or the docker install, set the variables on the ansible command accordingly.

Per default the files will be stored at `~/pixelflut-infrastructrue` this can be also overwritten with an variable.

```shell
# Use everything with defaults
ansible-playbook -i "<pixelflut-hostname or ip>," --user "<user of pixelflut remote host>" -K --extra-vars "monitoring_ip=<monitoring-hostname or ip>" install-pixelflut-host.yaml
ansible-playbook -i "<monitoring-hostname or ip>," --user "<user of monitoring remote host>" -K install-monitoring-host.yaml

# With all custom variables
ansible-playbook -i "<pixelflut-hostname or ip>," --user "<user of pixelflut remote host>" -K --extra-vars "monitoring_ip=<monitoring-hostname or ip> monitoring_ip6=<monitoring ip6> apt_upgrade=true install_docker=true working_dir=~/pixelflut-infrastructure" install-pixelflut-host.yaml
ansible-playbook -i "<monitoring-hostname or ip>," --user "<user of monitoring remote host>" -K --extra-vars "apt_upgrade=true install_docker=true working_dir=~/pixelflut-infrastructure" install-monitoring-host.yaml
```
Dont forget to replace all `<something>` in the commands above. *The `,` at the end of the -i parameter is intensional don't delete it.*