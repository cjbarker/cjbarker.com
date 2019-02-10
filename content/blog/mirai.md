+++
title = "Mirai Botnet"
date = "2016-10-06T19:20:04-07:00"
description = "DDoS Source Code Review"
type = "blog"
layout = "single"
+++

### Overview

This document provides an informal code review of the Mirai source code. The source code was acquired from the following GitHub repository: https://github.com/cjbarker/Mirai-Source-Code

*Note: There are some hardcoded Unicode strings that are in Russian. This could possibly be linked back to the author(s) country of origin behind the malware.*

### The Attack

On Tuesday, September 13, 2016 Brian Krebs’ website, KrebsOnSecurity, was hit with one of the largest distributed denial of service attacks (DDoS). Kerbs describes this attack in detail via his blog post “[KrebsOnSecurity Hit With Record DDoS](https://krebsonsecurity.com/2016/09/krebsonsecurity-hit-with-record-ddos/)”.

The attack methods deployed leveraged hundreds of thousands Internet of Things (IoT) devices that flooded the target, Krebs’ website, with various forms of network requests. The IoT devices’ requests exhausted connections to the target website preventing server resources from being able to handle any requests of malicious or benign intent.

The Mirai command ‘n control server (CNC) acquires bots via telnet, which is found enabled and exposed as a vulnerability in copious IoT devices running various forms of embedded Linux. Combined with a default hardware manufacturer login account, Mirai can quickly gain shell access on the device (bot). The Mirai CNC server is fed various commands through an admin interface for executing a Denial of Service (DoS) attack on the comprised device’s outbound network.

Additionally, the CNC harvests device IP addresses and meta-data acquired via bot scanning and discovery of a given devices. Once compromised the device will “phone home” to the CNC. Meanwhile the device continues to appear to operate normally while it is leveraged by the CNC server within a massive botnet composed of hundreds of thousands of IoT devices.

### Build

Build script is simple Bash script that provides standard functionality such as cleaning up artifacts, enabling compiler flags, and building debug or release binaries via go and gcc compilers.

The release build supports compiling bot binaries for numerous platforms (processors & associated instruction sets): SPC, MIPS, x86, ARM (arm, 7, 5n), PowerPC, Motorola 6800, and SuperH (sh4).

### Command and Control (CNC)

This is the command and control (CNC) logic that a server(s) applies to the botnet. It is all Go source code that defines various APIs and command functions to execute per device “bot”.

#### Admin

There is an administrative login and supported functionality via [**admin.go**](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/cnc/admin.go) This is the primary admin interface for issues controls to execute against the botnet (e.g. create an admin user, initiate an attack, etc.).

My favorite gem within here is upon establishing a login connection to the CNC server the user is treated with a great STDOUT welcome prompt of “I love chicken nuggets”, or at least that’s what Google Translate provided from the [prompt.txt](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/prompt.txt)

From here the user must provide the appropriate credentials (username & password), which are validated against a MySQL DBMS via [**database.go**](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/cnc/database.go)

Once successfully authenticated the server gives the allusion that it hides the hijacked connection from netstat and remove any traces of access on the machine (e.g. environment variables previously set). It prints to STDOUT that it’s executing such trace removal, but in reality it does nothing.

Next the admin panel will provide an updated count of the total number of bots connected and wait for command input such as attack type, duration length and number of bots. This is the primary interface for issuing attack commands to the botnet.

#### Client List

The [**clientList.go**](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/cnc/clientList.go) contains all associated data to execute an attack including a map/hashtable of all the bots allocated for this given attack. The code is responsible for maintaining multiple queues depending on the bot’s state of execution (e.g. ready for attack, attacking, delete/finished current attack.

#### Attack

[**attack.go**](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/cnc/attack.go) is responsible for handling the attack request initiated by the CNC server. It parses the shell command provided via the Admin interface, formats & builds the command(s), parses the target(s), which can be comma delimited list of targets, and sends the command down to the appropriate bots via [**api.go**](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/cnc/api.go)

Interesting point is that the allowed threshold duration that a per attack per bot can execute on (minimum of 1 second to maximum of 60 minutes).

#### API

The [**api.go**](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/cnc/api.go) is responsible for sending the command(s) to an individual bot from the CNC server.

It does enforce some rules/bounds checking. For example, CNC users are allocated N number of maximum bots they can utilized in a given attack. Unless you’re an administrator you’re bound to a limit on the number of bots you are allocated.

Additionally, it will check whether or not the given target has been white listed within the database.

Lastly, the logic will verify the bots state. If the bot is already in use it will be removed/ignored from the attack request.

#### Main

[**main.go**](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/cnc/main.go) is the entry point into the CNC server’s binary. It listens for incoming TCP connections on port 23 (telnet) and 101 (api bot responses). If a connection is received on the API port it is handled accordingly within api.go.

Meanwhile if a telnet connection is established the source/incoming IP address is acquired added as a newly compromised machine to the botnet (clientList).

### Bot

Within the bot directory are various attack methods the CNC server sends to the botnet for executing a DDoS against its target.

#### UDP Attacks

The bots support a few different forms of attack over the User Datagram Protocol (UDP). The source code [**attack_udp.c**](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/bot/attack_udp.c) implements the following attacks to be carried out by an unsuspected IoT (bot) device:

1. [Generic Routing Encapsulation](www.phenoelit.org/irpas/gre.html) (GRE) Attack
2. TSource Query — [Reflective Denial of Service](https://www.us-cert.gov/ncas/alerts/TA14-017A) (bandwidth amplification)
3. DNS Flood via Query of type A record (map hostname to IP address)
4. Flooding of random bytes via plain packets

#### TCP Attacks

As with UDP there are several attack types supported via the Transmission Control Protocol (TCP) within [**attack_tcp.c**](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/bot/attack_tcp.c)

1. [SYN Flood](https://en.wikipedia.org/wiki/SYN_flood)
2. [ACK Flood](https://www.staminus.net/a-ddos-attack-explained-tcp-ack/)
3. [PSH Flood](https://www.staminus.net/a-ddos-attack-explained-psh-flood/)

#### HTTP Attacks

In addition to the malformed and/or UDP or TCP packet floods, Mirai bots also support DoS over HTTP within the [**attack_app.c**](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/bot/attack_app.c)

Once a connection is successfully established (keep-alive is supported) the bot will send an HTTP GET or POST consisting of numerous cookies and random payload data when applicable (e.g. POST). Numerous valid user-agents are utilized to masquerade the requests as valid clients. As long as the connection is held (receives valid response) the target endpoint is continually flooded with HTTP requests originated from the bot.

#### Scanner

In addition to the attacks the bots will also do brute force scanning of IP addresses via [**scanner.c**](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/bot/scanner.c) in search of other devices to acquire within the botnet. The bot looks for any available IP address ([brute force via select set of IP ranges](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/bot/scanner.c#L674)) and apply a port scan (SYN scan) against it.

If the bot is able to successfully connect to an IP and open port then it will attempt to authenticate by running through a [dictionary of known credentials](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/bot/scanner.c#L124) (brute force authN) or check if it’s able to connect directly via telnet. If authentication or telnet session negotiation succeeds the bot will then attempt to enable the system’s shell/sh and drop into the shell (if needed and not already in shell).

Once the shell access is established the bot will verify its login to the recently acquired device. If it is verified and working telnet session the [information is reported back](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/bot/scanner.c#L901) (victim IP address, port, and authentication credentials) to the command and control server. The CNC server’s [domain defaults to cnc.chageme.com](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/bot/table.c#L18) The CNC server has a corpus of available machines that it can now successfully control as it sees fit by pushing down the bot binary and executing the appropriate attack command.

#### Killer

The [**killer.c**](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/bot/killer.c) provides functionality to kill various processes running on the bot (e.g. Telnet, SSH, etc.).

#### Main

[**main.c**](https://github.com/cjbarker/Mirai-Source-Code/blob/master/mirai/bot/main.c) is the entry point into the bot’s executable. It is responsible for establishing a connection back to the CNC server, initiating attacks, killing procs, and scanning for additional devices in hopes of commandeering them within the botnet.

### What Wasn't Covered?
Due to time constraints and/or lack of interest the following directories and associated source code was not reviewed:

[**tools**](https://github.com/cjbarker/Mirai-Source-Code/tree/master/mirai/tools) — utility code to do things such as translating data encoding, resource clean up, etc.

[**loader**](https://github.com/cjbarker/Mirai-Source-Code/tree/master/loader) — leverages wget or tftp to load (push) the malware onto unsuspecting devices

### How can we prevent such future attacks?

A week after the Krebs DDoS a similar attack at [1 Tbps was launched on a French ISP](https://thehackernews.com/2016/09/ddos-attack-iot.html). This was the largest recorded DDoS to date.

I am not sure we can prevent such massive attacks. Potentially helpful could be regulatory influence in the government requiring manufactures to adhere to a security standard and/or keeping firmware up-to-date for N years. This could potentially be similar to how the auto industry works with guarantee automobile manufactured parts up to a certain length of time.

At the very least, if your IoT device supports password changes or administrative account disablement then do it.

Good luck, have fun and be safe.
