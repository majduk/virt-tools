# HTTP Proxy container

This creates a apache2 based https(s) proxy.

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

