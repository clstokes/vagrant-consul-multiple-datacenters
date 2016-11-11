# vagrant-consul-multiple-datacenters

Creates a Consul cluster with two datacenters with one Consul server and one
Consul client in each datacenter. The Consul datacenters are connected across
the "WAN".

```
dc1                  dc2
===                  ===
dc1_client           dc2_client
dc1_server           dc2_server
```

Based on CentOS, using `bento/centos-7.2` from the wonderful https://github.com/chef/bento project.

## Usage

```
vagrant up
```
