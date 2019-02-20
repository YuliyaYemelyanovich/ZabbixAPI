#!/bin/bash

yum install -y http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum install -y zabbix-agent 
sed -i 's/Server=127.0.0.1/Server=192.168.56.100/; s/ServerActive=127.0.0.1/ServerActive=192.168.56.100/; s/# ListenIP=0.0.0.0/ListenIP=0.0.0.0/; s/# ListenPort=10050/ListenPort=10050/; s/# StartAgents=3/StartAgents=3/; s/# DebugLevel=3/DebugLevel=3/' /etc/zabbix/zabbix_agentd.conf


systemctl enable zabbix-agent
systemctl start zabbix-agent


