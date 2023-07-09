# WSL Port Forwarding

A simple script to add or remove port forwarding (and associated firewall rule).

## Usage

> NOTE: This script must be run as administrator.

```
wsl-pf <add|remove> <port> [-i <ip_address> | -d <wsl_distro_name>]
```

You must indicate an IP address or a WSL distribution name.