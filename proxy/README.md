# HTTP Proxy container

This creates a apache2 based https(s) proxy.

## Creating the container
First create a profile:
```
lxc profile create proxy
cat proxy_profile.yaml | lxc profile edit proxy
lxc launch ubuntu:xenial proxy --profile proxy
```
This is a time required for apache2 to be installed within the container:
```
sleep 30
```
Configure the apache2 server within the container:
```
lxc file push 000-default.conf proxy/etc/apache2/sites-available/000-default.conf
lxc file push ports.conf proxy/etc/apache2/ports.conf
lxc exec proxy service apache2 restart
```

## Using the container

### Set up the resolver
It is best to set up your host to resolve LXD names. This can be done in multiple ways depending on your local resolver:
- [systemd-resolve on Ubuntu 18.04](https://blog.simos.info/how-to-use-lxd-container-hostnames-on-the-host-in-ubuntu-18-04/)
- [NetworkManager](https://lists.linuxcontainers.org/pipermail/lxc-users/2016-September/012260.html)

- Network manager with dnsmasq: 
```
root@michal-laptop:~# cat /etc/NetworkManager/dnsmasq.d/lxd 
server=/lxd/10.146.247.1
server=/247.146.10.in-addr.arpa/10.146.247.1

root@michal-laptop:~# cat /etc/NetworkManager/NetworkManager.conf 
[main]
plugins=ifupdown,keyfile
dns=dnsmasq
#dns=default
#ignore-auto-dns=true

[ifupdown]
managed=false

[device]
wifi.scan-rand-mac-address=no
```

### Configure remote forwarding
This is best done using ssh config file (~/.ssh/config):

```
Host my-remote-host
  HostName my-remote-host
  RemoteForward 8080 proxy.lxd:8080
```

### Use it

On the remote host just export:
```
export http_proxy=http://127.0.0.1:8080/
export https_proxy=http://127.0.0.1:8080/
```
You can also add this to a file:
- `~/.bashrc` for just your user
- `/etc/environment` for all users

Note that the proxy will be available only when you are connected.