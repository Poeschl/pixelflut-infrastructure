# Ansible Installer

When you are reading this your might be right before installing the Pixelflut infrastructure via ansible.

Before doing that, make sure the correct configuration is set in the `.env` file on the project root.

The given Ansible playbooks will work on any apt-base linux system and also updates all installed packages as default.
After that it will install docker and docker-compose (the docker service will be restarted if existing) as well as
transfering all needed files to the corresponding hosts.
For installing it will sudo the remote user, the password for this will be asked before starting the playbook.

It can also be used to transfer changes in your local folder.
For that just execute the playbook again and your changes on the local config or docker-compose file will be transfered.

## Requirements

To use this playbook external roles and modules are required. Install them with (from the `ansible` folder):

```shell
ansible-galaxy install -r requirements.yaml
```

## Install

After filling the `.env` file in the project root, insert your ips for the *two* hosts in `config.yaml`.
Here you can also adjust some basic settings, as installing / upgrading docker and update the system.
Per default the files will be stored at `~/pixelflut-infrastructrue` this can be also overwritten with an variable.

Then the playbook `install-hosts.yaml` needs to be executed as follows:

```shell
ansible-playbook -i "config.yaml" --user "<user on pixelflut remote host>" --private-key "<path to private key>" install-hosts.yaml

# Or if username / password is used
ansible-playbook -i "config.yaml" --user "<user on pixelflut remote host>" -K install-hosts.yaml

```

Dont forget to replace all `<something>` in the commands above.

### Notes

It should be possible to execute the install on one host when insert the same ip in the `config.yaml`.
You will need to adjust things manually then!
Use at your own risk.
