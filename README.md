# SmartDNS China List 安装脚本

## 介绍

用于优化您最喜爱的 DNS 服务器的中国特定 SmartDNS 配置。  

- [SmartDNS](https://github.com/pymumu/smartdns) 适用版本：Release 43 及以上

- 提升解析中国域名的速度

- 尽可能获取距离您最近的最佳 CDN 节点，但不会影响海外 CDN 结果

- 阻止 ISP 在 NXDOMAIN 结果中显示广告

### 细节说明

本项目仅使用 `bash` 脚本生成 SmartDNS 配置文件，并对部分配置文件逻辑进行了修改。  

不再生成测速相关的 `domain-rules` 配置，避免干扰 SmartDNS 现有测速模式。  

DNS 服务器组配置文件为 `dns-group.china.smartdns.conf` ：  

```conf
## 本项目 DNS 服务器组规则

server 223.5.5.5 -group flash -exclude-default-group
server 119.29.29.29 -group flash -exclude-default-group
server 114.114.114.114 -group flash -exclude-default-group
```

由于添加了 `-exclude-default-group` 参数，只有规则内域名会使用该 DNS 服务器组。  

同时，本项目使用 DNS 服务器组 `flash` 替换了单个上游 DNS 服务器：  

```conf
## 上游项目 nameserver 规则

nameserver /abc.com/114.114.114.114
nameserver /xyz.net/114.114.114.114

## 本项目 nameserver 规则

nameserver /abc.com/flash
nameserver /xyz.net/flash
```

此时，SmartDNS 在请求规则内域名时，将向指定的上游 DNS 服务器组发送请求。  

- 上游 DNS 服务器：
  - `223.5.5.5 119.29.29.29 114.114.114.114`

- 配置文件路径：
  - `/etc/smartdns.d`

- 配置文件名：
  - `dns-group.china.smartdns.conf`
  - `apple.china.smartdns.conf`
  - `google.china.smartdns.conf`
  - `accelerated-domains.china.smartdns.conf`
  - `bogus-nxdomain.china.smartdns.conf`

### 使用方法

1. 下载本安装脚本，并赋予可执行权限

    ```bash
    ## 下载安装脚本
    $ curl -LR -O https://raw.githubusercontent.com/CallMeR/smartdns_china_list_installer/main/smartdns_plugin.sh

    ## 设置安装脚本权限
    $ chmod +x smartdns_plugin.sh
    ```

2. 编辑所需的上游 DNS 服务器列表（可选）

3. 使用 `root` 权限运行脚本：

    ```bash
    ## 执行安装脚本
    $ sudo ./smartdns_plugin.sh
    ```

4. 定期执行脚本（可选）

    ```bash
    ## 编辑系统定时任务
    $ sudo crontab -e

    ## 定时任务配置项
    
    20 5 * * * /usr/bin/bash /path/to/smartdns_plugin.sh
    ```

### 特别鸣谢

没有这些项目，就不会有本项目 :)

- Github: [dnsmasq-china-list](https://github.com/felixonmars/dnsmasq-china-list)

- Github: [smartdns](https://github.com/pymumu/smartdns)

### License

```txt
Copyright © 2023 Nomad Chen <nomadfun@outlook.com>
This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the LICENSE file for more details.
```