# DNS-practice-2
In this practice I have created 2 virtual machines using Vagrant in which I have configured a primary DNS Server and a secondary DNS Server using a provision file.

## Table of contents
  - [Vagrant file configuration](#vagrant-file-configuration)
  - [Provision script](#provision-script)
  - [Primary DNS Server configuration](#primary-dns-server-configuration)
  - [Secondary DNS Server configuration](#secondary-dns-server-configuration)
  - [Testing](#testing)
  - [Create them!](#create-them)

## Vagrant file configuration
I set the general configuration of the virtual machines (RAM, Linux distribution...) and in each one the hostname, fixed IP and provision file path.
```ruby
  config.vm.define "ns1" do |debian|
    debian.vm.hostname = "ns1"
        #Network card, private network mode
        debian.vm.network :private_network, ip: "192.168.57.10"
    debian.vm.provision "shell", path: "provision.sh"
    end
```
*Fragment of: Vagrantfile*
 
## Provision script
Here I make a simple script to install Bind9 and to copy the configuration files with the correct settings.

## Primary DNS Server configuration
Steps:
1. Configure the server to IP version 4 in `/etc/bind/named`.
    ```
    OPTIONS="-u bind -4"
    ```
2. Set the correct parameters in the _named.conf.options_ file.
   -  Allow data's transfer to the secondary
   ```
    acl slaves {
        192.168.57.11;
    };
    options {
        allow-transfer { slaves; };
    };
    ```
    - Retransfer queries that your server can't resolve
   ```
    forwarders {
		1.1.1.1;
	};
    ```
3. Set the forward and reverse zones in the _named.conf.local_ file.
   ```
   zone "asir.izv" {
        type master;
        file "/var/lib/bind/asir.izv.dns";
    };

    zone "57.168.192.in-addr.arpa" {
        type master;
        file "/var/lib/bind/asir.izv.rev";
    };
   ```
4. Create the zone files as required.
```
; Name Servers (NS)
@ 			IN	NS 		ns1.asir.izv.
@ 			IN	NS 		ns2.asir.izv.

; Server IP
ns1			IN  A 		192.168.57.10
ns2			IN  A 		192.168.57.11

; Hosts addresses (A)
server1		IN	A 		192.168.57.100
server2 	IN  A 		192.168.57.101
mail		IN	A 		192.168.57.102

; Aliases
www		 	IN 	CNAME 	server1.asir.izv.

; Mail Server
@			IN  MX 10	 mail.asir.izv.

```
*Fragment of the direct resolution zone file*

```
; Name Servers
@ 		IN 	NS ns1.asir.izv.
@ 		IN 	NS ns2.asir.izv.

; Hosts
10		IN  PTR ns1.asir.izv.
11		IN  PTR ns2.asir.izv.
100		IN  PTR server1.asir.izv.
101		IN  PTR server2.asir.izv.
102		IN  PTR mail.asir.izv.

```
*Fragment of the reverse resolution zone file*

I have also adjusted some parameters like the negative cache TTL to my preference.
   
## Secondary DNS Server configuration
Steps:
1. Configure the server to IP version 4 as on the primary.
2. Modify the `named.conf.options` file as on the primary but now it should not allow transfer.
```
    allow-transfer { none; };
```
3. Modify the `named.conf.local` file as on the primary but specify the slave type and who the masters are.
```
zone "asir.izv" {
	type slave;
	file "/var/lib/bind/asir.izv.dns";
	masters { 192.168.57.10; };
};

zone "57.168.192.in-addr.arpa" {
	type slave;
	file "/var/lib/bind/asir.izv.rev";
	masters { 192.168.57.10; };
};
```

I have also included a `resolv.conf` file to set to both servers their name servers.
```
nameserver 192.168.57.10
nameserver 192.168.57.11
```
*resolv.conf file*
```
cp /vagrant/files/resolv.conf /etc/
```
*Fragment of: provision.sh*

## Testing
To test if the servers are working as expected, you can execute the `test.bat` file added to this proyect just using the `.\test.bat [server-IP]` command.
Let's see it working!  
![test](https://github.com/xtabay00/practiceDNS-2/assets/151829005/593d2d2e-11e3-4035-ad67-0b4abb21c440)

 
## Create them!
To create the virtual machines you just need to:
1. Download and unzip the directory
2. Open a command line interface
3. Change the working directory to the directory you just download
    `cd /route/of/the/directory/DNS-practice`
4. Execute: `vagrant up`
