# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.define "zabbix-server" do |zs|
    zs.vm.box = "sbeliakou/centos-7.3-x86_64-minimal"
    zs.vm.network "private_network", ip: "192.168.56.100"
    zs.vm.provision 'shell', path: "zabbix_server.sh"
    zs.vm.provider "virtualbox" do |vb|
       vb.name = "Zabbix-server"
       vb.memory = "2048"
    end
  end

  config.vm.define "zabbix-agent-1" do |za|
    za.vm.box = "sbeliakou/centos-7.3-x86_64-minimal"
    za.vm.network "private_network", ip: "192.168.56.102"
    za.vm.provision 'shell', path: "zabbix_agent.sh"
    za.vm.provision 'shell', path: "agent_autoregistration.sh", args: "192.168.56.100 Zabbix-agent"
    za.vm.provider "virtualbox" do |vb|
       vb.name = "Zabbix-agent-1"
       vb.memory = "2048"
    end
  end
    
end
