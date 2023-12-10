# SmartDNS China List Installer

## Introduction

Chinese-specific SmartDNS configuration to improve your favorite DNS server. Best partner for chnroutes.  

- [SmartDNS](https://github.com/pymumu/smartdns) version: Release 43 and above

- Improve resolve speed for Chinese domains

- Get the best CDN node near you whenever possible, but don't compromise foreign CDN results so you also get best CDN node for your VPN at the same time

- Block ISP ads on NXDOMAIN result

### Details

This project generates SmartDNS configuration files using a bash script and modifies some of the configuration file logic.  

It no longer generates speed testing-related domain-rules configurations to avoid interfering with SmartDNS's existing speed testing mode.  

It replaces a single upstream DNS server with a DNS server group called `accelerate` :  

```conf
## Original nameserver rules

nameserver /abc.com/114.114.114.114
nameserver /xyz.net/114.114.114.114

## Modified nameserver rules

nameserver /abc.com/accelerate
nameserver /xyz.net/accelerate
```

With this configuration, when SmartDNS requests domain names specified in the rules, it sends the requests to the designated upstream DNS server group.  

The DNS server group configuration file is `server-group.china.accelerate.conf` :  

```conf
## Modified DNS server group rules

server 223.5.5.5 -group accelerate -exclude-default-group
server 119.29.29.29 -group accelerate -exclude-default-group
server 114.114.114.114 -group accelerate -exclude-default-group
server 114.114.115.115 -group accelerate -exclude-default-group
```

By adding the -exclude-default-group parameter, only domain names specified in the rules will use this DNS server group.  

- Upstream DNS servers:
  - `223.5.5.5 119.29.29.29 114.114.114.114 114.114.115.115`

- Configuration file path:
  - `/etc/smartdns.d`

- Configuration file names:
  - `server-group.china.accelerate.conf`
  - `apple.china.accelerate.conf`
  - `google.china.accelerate.conf`
  - `accelerated-domains.china.accelerate.conf`
  - `bogus-nxdomain.china.accelerate.conf`

### Usage

1. Download the installation script and give it execution permission.

    ```bash
    ## Download the installation script
    $ wget https://gitee.com/callmer/smartdns_china_list_installer/raw/main/smartdns_plugin.sh

    ## Set execution permissions for the script
    $ chmod +x smartdns_plugin.sh
    ```

2. Edit the required upstream DNS server list (optional).

3. Run the script with `root` permissions:

    ```bash
    ## Execute the installation script
    $ sudo ./smartdns_plugin.sh
    ```

4. Schedule the script to run periodically (optional).

    ```bash
    ## Edit the system's cron jobs
    $ sudo crontab -e

    ## Cron job configuration
    
    20 5 * * * /usr/bin/bash /path/to/smartdns_plugin.sh
    ```

### Special Thanks

Without these projects, this project would not exist :)

- Github: [dnsmasq-china-list](https://github.com/felixonmars/dnsmasq-china-list)

- Github: [smartdns](https://github.com/pymumu/smartdns)

### License

```txt
Copyright © 2023 Nomad Chen <nomadfun@outlook.com>
This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the LICENSE file for more details.
```