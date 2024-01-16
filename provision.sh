#!/bin/bash

#Set DEBIAN_FRONTEND before the installations
export DEBIAN_FRONTEND=noninteractiveconfiguration
    #for all questions to select the default and not ask, the "-y" modifier is just for Yes/no

#Previous steps
apt-get -y update
apt-get -y upgrade
    
#DNS servers configuration
    #Bind9 service installation
    apt-get install bind9 bind9utils bind9-doc -y
    #named file configuration to IPv4
    cp /vagrant/files/named /etc/default/

    #resolv.conf file configuration to set the DNS default name servers
    cp /vagrant/files/resolv.conf /etc/

    #named.conf.options and local files configuration on primary and secondary servers
    if [ $(cat /etc/hostname) == 'ns1' ]; then
        #primary
        cp /vagrant/files/named.conf.options.primary /etc/bind/named.conf.options
        cp /vagrant/files/named.conf.local.primary /etc/bind/named.conf.local
        cp /vagrant/files/asir.izv.dns /vagrant/files/asir.izv.rev /var/lib/bind/
    else 
        #secondary
        cp /vagrant/files/named.conf.options.secondary /etc/bind/named.conf.options
        cp /vagrant/files/named.conf.local.secondary /etc/bind/named.conf.local
    fi

    # Restart the named service
    systemctl restart named   


# Restore DEBIAN_FRONTEND after installations
unset DEBIAN_FRONTEND