# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  # Datacenter 1 - dc1
  config.vm.define "dc1_server" do |dc1_server|
    dc1_server.vm.box = "bento/centos-7.2"
    dc1_server.vm.network "private_network", ip: "192.168.33.2"

    dc1_server.vm.provision "shell", inline: <<-SHELL
     bash /vagrant/scripts/provision-consul-server.sh dc1 dc1_server
    SHELL
  end

  config.vm.define "dc1_client" do |dc1_client|
    dc1_client.vm.box = "bento/centos-7.2"
    dc1_client.vm.network "private_network", ip: "192.168.33.3"

    dc1_client.vm.provision "shell", inline: <<-SHELL
     bash /vagrant/scripts/provision-consul-client.sh dc1 dc1_client
    SHELL

    dc1_client.vm.provision "shell", inline: <<-SHELL
      /usr/local/bin/consul join 192.168.33.2          # join to dc1 lan
    SHELL
  end

  # Datacenter 1 - dc2
  config.vm.define "dc2_server" do |dc2_server|
    dc2_server.vm.box = "bento/centos-7.2"
    dc2_server.vm.network "private_network", ip: "192.168.33.4"

    dc2_server.vm.provision "shell", inline: <<-SHELL
     bash /vagrant/scripts/provision-consul-server.sh dc2 dc2_server
    SHELL

    dc2_server.vm.provision "shell", inline: <<-SHELL
      /usr/local/bin/consul join -wan 192.168.33.2     # join to dc1 wan
    SHELL
  end

  config.vm.define "dc2_client" do |dc2_client|
    dc2_client.vm.box = "bento/centos-7.2"
    dc2_client.vm.network "private_network", ip: "192.168.33.5"

    dc2_client.vm.provision "shell", inline: <<-SHELL
     bash /vagrant/scripts/provision-consul-client.sh dc2 dc2_client
    SHELL

    dc2_client.vm.provision "shell", inline: <<-SHELL
      /usr/local/bin/consul join 192.168.33.4          # join to dc2 lan
    SHELL

  end

end
