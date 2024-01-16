REM asir.izv test batch script
REM usage: test.bat <ipserver-ip>

@ECHO on

SET ipserver=%1

REM NAMESERVERS
nslookup -type=ns asir.izv %ipserver%
REM HOSTS
nslookup server1.asir.izv %ipserver%
nslookup server2.asir.izv %ipserver%
nslookup mail.asir.izv %ipserver%
REM ALIAS
nslookup www.asir.izv %ipserver%
REM MAIL
nslookup -type=mx asir.izv %ipserver%
REM REVERSE
nslookup 192.168.57.10 %ipserver%
nslookup 192.168.57.11 %ipserver%
nslookup 192.168.57.100 %ipserver%
nslookup 192.168.57.101 %ipserver%
nslookup 192.168.57.102 %ipserver%

@ECHO off
