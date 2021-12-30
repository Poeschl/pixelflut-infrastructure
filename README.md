# pixelflut-infrastructure
A docker-setup with pixelflut server (shoreline), VNC-relay and monitoring of the game.

With this tool you can start an pixelflut server, acting as VCN-Server.
The game and server are monitored with prometheus and grafana.
A VNC-Relay/Multiplexer is provided to take the load of all the people watching the game from the pixelflut server.

For real usage - e.g. at large hacker events - i definitive suggest using two servers:
Server 1 to run only the pixelflut server.
Server 2 to run the VNC-Relay and Montitoring-Setup (this tool).
People watching connect with their VNC-Viewer to the second server.
When starting this tool you can choose to start your own pixelflut server, or monitor an other server.
Important: This tool is made for the [shoreline pixelflut server](https://github.com/TobleMiner/shoreline), other servers likely wont work (dont have VNC and expose statistics).

## Preperation
You must have docker and docker-compose installed. See https://docs.docker.com/get-docker/ and https://docs.docker.com/compose/install/.

After that adjust the `.env` file to your requirements, the variables will be used by the starting docker containers.
When everything is set, execute `docker-compose -f docker-compose.pixelflut-host.yml up` on your host for the Pixelflut server.
Afterwards execute `docker-compose -f docker-compose.monitoring-host.yml up` on the host intended for monitoring and forwarding.
Make sure that the `.env` file is identical on both machines.

If only one host is used start both docker-compose files on this machine.
Please check if the `pixelflut_host` is then set to `localhost`.

## Overview of services
![Overview of services](docs/images/services.png?raw=true "Overview of services")

## Grafana Pixelflut Dashboard

The data in Grafana will be persisted between restarts and retains for 14 days.

![Grafana Pixelflut Dashboard](docs/images/dashboard.png?raw=true "Grafana Pixelflut Dashboard")

## Thanks
To https://github.com/sbernauer/pixelflut-infrastructure for the initial infrastructure.
Powered by https://github.com/TobleMiner/shoreline and https://github.com/TobleMiner/vncmux.
