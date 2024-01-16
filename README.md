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

Let's also check that the zone transfer has been done correctly between the master and the slave.  
1. We can see the log in `/var/log/syslog`.
   ![transfer-logs](https://github.com/xtabay00/practiceDNS-2/assets/151829005/e3a4ef1e-61b3-4623-928b-b240962e4541)

2. We can use an AXFR request from the secundary: `dig 192.168.57.10 asir.izv AXFR`
```
	; <<>> DiG 9.16.44-Debian <<>> 192.168.57.10 asir.izv AXFR
	;; global options: +cmd
	;; Got answer:
	;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 33924
	;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1
	
	;; OPT PSEUDOSECTION:
	; EDNS: version: 0, flags:; udp: 1232
	; COOKIE: 80bc67808d2081f20100000065a6dfe6db7d8e52ea8425d6 (good)
	;; QUESTION SECTION:
	;192.168.57.10.			IN	A
	
	;; AUTHORITY SECTION:
	.			10688	IN	SOA	a.root-servers.net. nstld.verisign-grs.com. 2024011601 1800 900 604800 86400
	
	;; Query time: 0 msec
	;; SERVER: 192.168.57.10#53(192.168.57.10)
	;; WHEN: Tue Jan 16 19:58:30 UTC 2024
	;; MSG SIZE  rcvd: 145
	
	asir.izv.		86400	IN	SOA	ns1.asir.izv.asir.izv. asaecam950.ieszaidinvergeles.org. 1 3600 1800 604800 7200
	asir.izv.		86400	IN	MX	10 mail.asir.izv.
	asir.izv.		86400	IN	NS	ns1.asir.izv.
	asir.izv.		86400	IN	NS	ns2.asir.izv.
	mail.asir.izv.		86400	IN	A	192.168.57.102
	ns1.asir.izv.		86400	IN	A	192.168.57.10
	ns2.asir.izv.		86400	IN	A	192.168.57.11
	server1.asir.izv.	86400	IN	A	192.168.57.100
	server2.asir.izv.	86400	IN	A	192.168.57.101
	www.asir.izv.		86400	IN	CNAME	server1.asir.izv.
	asir.izv.		86400	IN	SOA	ns1.asir.izv.asir.izv. asaecam950.ieszaidinvergeles.org. 1 3600 1800 604800 7200
	;; Query time: 4 msec
	;; SERVER: 192.168.57.10#53(192.168.57.10)
	;; WHEN: Tue Jan 16 19:58:30 UTC 2024
	;; XFR size: 11 records (messages 1, bytes 361)
```
*Request's output*

3. We also check than from another computer on the same network the previous request does not work.
```
	; <<>> DiG 9.16.44-Debian <<>> 192.168.57.10 asir.izv AXFR
	;; global options: +cmd
	;; Got answer:
	;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 2940
	;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1
	
	;; OPT PSEUDOSECTION:
	; EDNS: version: 0, flags:; udp: 512
	;; QUESTION SECTION:
	;192.168.57.10.                 IN      A
	
	;; AUTHORITY SECTION:
	.                       86377   IN      SOA     a.root-servers.net. nstld.verisign-grs.com. 2024011601 1800 900 604800 86400
	
	;; Query time: 36 msec
	;; SERVER: 10.0.2.3#53(10.0.2.3)
	;; WHEN: Tue Jan 16 20:16:35 UTC 2024
	;; MSG SIZE  rcvd: 117
	
	; Transfer failed.
```
*Request's output*
 
## Create them!
To create the virtual machines you just need to:
1. Download and unzip the directory
2. Open a command line interface
3. Change the working directory to the directory you just download
    `cd /route/of/the/directory/DNS-practice`
4. Execute: `vagrant up`
