#!/bin/bash

set -ex

if [ -z "$1" ]; then
    echo "First argument must be supplied as Consul datacenter."
    exit 1
fi

if [ -z "$2" ]; then
    echo "Second argument must be supplied as Consul node name."
    exit 1
fi

CONSUL_VERSION=0.7.0
CONSUL_TEMPLATE_VERSION=0.16.0

CONSUL_DATACENTER=$1
CONSUL_NODE_NAME=$2
CONSUL_BOOTSTRAP_EXPECT=1

CONSUL_ADVERTISE_ADDR=$(/usr/sbin/ifconfig ens32 | grep "inet " | awk '{ print $2 }')

#######################################
# CONSUL
#######################################

# install dependencies
echo "Installing consul dependencies..."
sudo yum install -q -y unzip wget

# install consul
echo "Fetching consul..."
cd /tmp/

# Cache downloads for other VMs to save time and bandwidth.
CONSUL_ZIP=/vagrant/bin/consul_${CONSUL_VERSION}_linux_amd64.zip
if [ ! -f $CONSUL_ZIP ]; then
  mkdir -p /vagrant/bin
  wget -q https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip -O $CONSUL_ZIP
fi

echo "Installing consul..."
unzip $CONSUL_ZIP
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul
sudo mkdir -pm 0600 /etc/systemd/system/consul.d

# setup consul directories
sudo mkdir -pm 0600 /opt/consul
sudo mkdir -p /opt/consul/data

echo "Consul installation complete."

#######################################
# CONSUL CONFIGURATION
#######################################

sudo tee /etc/systemd/system/consul.d/consul.json > /dev/null <<EOF
{
  "datacenter": "${CONSUL_DATACENTER}",
  "node_name": "${CONSUL_NODE_NAME}",

  "data_dir": "/opt/consul/data",
  "ui": true,

  "client_addr": "0.0.0.0",
  "bind_addr": "0.0.0.0",
  "advertise_addr": "${CONSUL_ADVERTISE_ADDR}",

  "leave_on_terminate": false,
  "skip_leave_on_interrupt": true
}
EOF

sudo tee /etc/systemd/system/consul.service > /dev/null <<EOF
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/sysconfig/consul
Restart=on-failure
ExecStart=/usr/local/bin/consul agent $CONSUL_FLAGS -config-dir=/etc/systemd/system/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target

EOF

#######################################
# CONSUL-TEMPLATE
#######################################

# install dependencies
echo "Installing consul-template dependencies..."
sudo yum install -q -y unzip wget

# install consul-template
echo "Fetching consul-template..."
cd /tmp/

# Cache downloads for other VMs to save time and bandwidth.
CONSUL_TEMPLATE_ZIP=/vagrant/bin/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip
if [ ! -f $CONSUL_TEMPLATE_ZIP ]; then
  mkdir -p /vagrant/bin
  wget -q https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.zip -O $CONSUL_TEMPLATE_ZIP
fi

echo "Installing consul-template..."
unzip $CONSUL_TEMPLATE_ZIP
sudo chmod +x consul-template
sudo mv consul-template /usr/bin/consul-template

echo "Consul-template installation complete."

#######################################
# DNSMASQ
#######################################

echo "Installing Dnsmasq..."

sudo yum install -q -y dnsmasq

echo "Configuring Dnsmasq..."

sudo sh -c 'echo "server=/consul/127.0.0.1#8600" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "listen-address=127.0.0.1" >> /etc/dnsmasq.d/consul'
sudo sh -c 'echo "bind-interfaces" >> /etc/dnsmasq.d/consul'

echo "Restarting dnsmasq..."
sudo service dnsmasq restart

echo "dnsmasq installation complete."

#######################################
# START SERVICES
#######################################

sudo systemctl enable consul.service
sudo systemctl start consul
