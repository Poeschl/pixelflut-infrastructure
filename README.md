# pixelflut-infrastructure

A docker-setup with pixelflut server (shoreline), VNC-relay and monitoring of the game.

With this tool you can start an pixelflut server, acting as VNC-Server.
The game and server are monitored with prometheus and grafana.
A VNC-Relay/Multiplexer is provided to take the load of all the people watching the game from the pixelflut server.

For real usage - e.g. at large hacker events - i definitive suggest using two servers:
Server 1 to run only the pixelflut server.
Server 2 to run the VNC-Relay and Montitoring-Setup (this tool).
People watching connect with their VNC-Viewer to the second server.
When starting this tool you can choose to start your own pixelflut server, or monitor an other server.
Important: This tool is made for the [shoreline pixelflut server](https://github.com/TobleMiner/shoreline), other servers likely wont work (dont have VNC and expose statistics).

The Pixelflut infrastructure also contains an hourly wipe of the canvas.
This might be handy to clear leftovers.
It is done by flooding the background image from the `wiper` directory with 1 connection to the canvas.

## Preperation

You must have docker and docker-compose installed. See https://docs.docker.com/get-docker/ and https://docs.docker.com/compose/install/.

If you want to use Ansible to set everything up for you, the last preperation section is what you are looking for.

After that adjust the `.env` file to your requirements, the variables will be used by the starting docker containers.
When everything is set, execute `docker-compose -f docker-compose.pixelflut-host.yml up` on your host for the Pixelflut server.
Afterwards execute `docker-compose -f docker-compose.monitoring-host.yml up` on the host intended for monitoring and forwarding.
Make sure that the `.env` file is identical on both machines.

If only one host is used start both docker-compose files on this machine.
Please check if the `pixelflut_host` is then set to `localhost`.

### Pixelflut host

Don't forget to limit the connections per IP on the Pixelflut host, to make it a little challenging for all players.
As iptables is available everywhere use those two commands to limit to 10 (or what you like) connections for each IPv4 and IPv6.

```shell
iptables -A INPUT -p tcp -m tcp --dport 1234 --tcp-flags FIN,SYN,RST,ACK SYN -m connlimit --connlimit-above 10 --connlimit-mask 32 --connlimit-saddr -j REJECT --reject-with icmp-port-unreachable
ip6tables -A INPUT -p tcp -m tcp --dport 1234 --tcp-flags FIN,SYN,RST,ACK SYN -m connlimit --connlimit-above 10 --connlimit-mask 128 --connlimit-saddr -j REJECT --reject-with icmp6-port-unreachable
```

Also block the direct VNC port on the Pixelflut host, since all clients should use the VNCmux connection.

```shell
iptables -I INPUT --proto tcp --dport 5901 -j REJECT
# Allow your monitoring server the connection
iptables -I INPUT --source <ip of monitoring server> --proto tcp --dport 5901 -j ACCEPT

ip6tables -I INPUT --proto tcp --dport 5901 -j REJECT
# Allow your monitoring server the connection
ip6tables -I INPUT --source <ip of monitoring server> --proto tcp --dport 5901 -j ACCEPT

```

### Running on Non-Linux

If you intend to use this infrastructure on a non-linux system, make sure to comment out `network_mode: "host"` in the `docker-compose.*.yml` files.
Docker Desktop does not support this network mode. On linux it does increase the performance, so its enabled on default.

### Ansible installer

In the `ansible` folder are ansible playbooks ready to distribute this repository to two hosts and set them up and running.
More on the [README](ansible/README.md) inside the folder.

## Overview of services

![Overview of services](docs/images/services.png?raw=true "Overview of services")

## HTTPS via Traefik

For a secure TLS connection Traefik is used for the monitoring server and provides a encrypted connection to Grafana.
The certificate for the connection is recieved from Let's encrypt and is stored in a internal volume, so it stays persistant between restarts.
The traefik Dashboard is available under https://\<hostname\>/traefik/dashboard, in case the domain correctly entered in the `.env` file.

If an https connection is not what you want or you don't trust Let's Encrypt, follow the commented instructions on the grafana service in `docker-compose.monitoring-host.yaml`.

## Grafana Pixelflut Dashboard

The grafana dashboard is available und https://\<hostname\>/grafana.

The data in Grafana will be persisted between restarts and retains for 14 days.

![Grafana Pixelflut Dashboard](docs/images/dashboard.png?raw=true "Grafana Pixelflut Dashboard")

## Thanks

To https://github.com/sbernauer/pixelflut-infrastructure for the initial infrastructure.

Powered by https://github.com/TobleMiner/shoreline and https://github.com/TobleMiner/vncmux.
