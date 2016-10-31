# CIS Security Bencmarks for Ubuntu

## Recommendations

This recommendations provide prescriptive guidance for system and application administrators who plan to develop, deploy,
assess, or secure solutions that incorporate Ubuntu server.

### 1 - Patching and Software Updates

Newer patches may contain security enhancements that would not be available through the latest full update. As a result, it is recommended that the latest software patches be used to
take advantage of the latest functionality.

### 2 - Filesystem Configuration

Directories that are used for system-wide functions can be further protected by placing them on separate partitions. This provides protection for resource exhaustion and enables the use of mounting options that are applicable to the directory's intended use. It is recommended to store user's data on separate partitions and have stricter mount options.

According to the CIS rules, the partitioning scheme would be the following :

```
| Partition       | Mount options                 |
|-----------------|-------------------------------|
| /               | nodev, nosuid, noexec         |
| /home           | nodev                         |
| /tmp            | bind mount /var/tmp to /tmp   |
| /var            |                               |
| /var/log        |                               |
| /var/log/audit  |                               |
```
The section 2 is made to fulfill this particular scheme. If for any reason, you can not use this partitioning, then, you can disable partitioning checking by changing the file `default/main.yml` and set the value of `partitioning` to `False`

### 3 - Secure Boot Settings

Malicious code try to start as early as possible during the boot process, so boot loader configuration files must be protected. Fixing permissions to read and write for root only prevents non-root users from seeing the boot parameters or changing them. Non-root users who read the boot parameters may be able to identify weaknesses in security upon boot and be able to exploit them. It is recommendated to protect boot loader with a boot password will prevent an unauthorized user from entering boot parameters or changing the boot partition.

### 4 - Process Hardening

During execution the process offers a surface of vulnerability, this section aims to reduce the risk to exploit vulnerabilty:

- Core dump can be used to glean confidential information and must be restricted.
- Activating whenever possible processors function to prevent exploitation of buffer overflow vulnerabilities.
- Make difficult to write memory page exploits using random placing virtual memory regions.
- etc ...

#### 4.5 - AppArmor Activation

The apparmor installation enforce the new isolation profiles for known applications. A restart of the services is needed to completely setup the new policy. If the restart is not performed, the following error will appear:

    1 processes are unconfined but have a profile defined.
    /usr/sbin/rsyslogd

We already provide the [rsyslog restart](https://github.com/awailly/cis-ubuntu-ansible/issues/7#issuecomment-102357799), but it is not possible to do this for all services. Check if the `sudo service <unconfined service name> restart` command solve the issue, and else fill an issue.

### 5 - OS Services

It order to prevent the exploitation of vulnerabilities, it is highly adviced to disable all services that are not required for normal system operation. If a service is not enabled, it cannot be exploited ! Therefore, legacy services (NIS, rsh client/server, telnet, ...) must be not active on the system.

### 6 - Special Purpose Services

Some services that are installed on servers need to be specifically actived. If any of these services are not required, it is recommended that they be disabled or deleted from the system to reduce the potential attack surface. The X Window system that provides a Graphical User Interface (GUI) to users is typically used on desktops where users login, but not on servers. Remove it if your organization not specifically requires graphical login access via X Windows. For the same reason, it is recommended to disable Avahi, a free zeroconf service discovery protocol, if this service is not needed.

At last, it is likely that a service that is installed on a server specifically need to run this service, uninstall or disable others services : DHCP server, CUPS (Common Unix Print System) protocol, HTTP Proxy server, Samba, IMAP and POP server, LDAP, NFS and RPC, DNS server, FTP server, etc ...  .

### 7 - Network Configuration and Firewalls

This section tests aim to secure network and firewall configuration. If the system has at least two interfaces, it can act as a router, but the system must be considered as host only and not as a router, so, network parameters must be set to avoid any routing functions and all IP functionalities used on a router must be disable. The IPv6 networking protocol is replacing Ipv4, but it must be disable if IPv6 is not used. In case of wireless network is present but not used, wireless devices can be disabled to reduce the potential attack surface.

It is recommended to filter network access using TCP Wrapper: Hosts authorized and hosts not permitted to connect to the system must be specified.

The Linux kernel modules support several network protocols that are not commonly used (ex: Datagram Congestion Control Protocol (DCCP), Stream Control Transmission Protocol (SCTP), etc...) . If these protocols are not needed, it is recommended that they be disabled in the kernel.

Finally, it is encourage to activate the Firewall. IPtables is an application that allows a system administrator to configure the IPv4 tables, chains and rules provided by the Linux kernel firewall.

### 8 - Logging and Auditing

Intrusions attempts and others suspicious system behavior must be monitor using log monitoring and auditing tools. It is recommended that rsyslog be used for logging and auditd be used for auditing. In addition to the local log files, it is also recommended that system collect copies of their system logs on a secure, centralized log server via an encrypted connection (*). Indeed, the attacker modifies the local log files on the affected system.

Because it is often necessary to correlate log information from many different systems it is recommended that the time be synchronized among systems and devices connected to the local network.

(*) Warning : Do not configure the IP address for remote logs server with the localhost address (127.0.0.1), if so, rsyslog will hit 100% of the CPU usage.


### 9 - System Access, Authentication and Authorization

This section aims to reinforce system protection against the exploitation of software utilities or modules in Unix operating systems to gain elevated privileges.

Cron is a time-based job scheduler used in Unix operating systems to set up and maintain software environments with scheduling jobs. Granting read or write access to cron configuration files could provide unprivileged users with the ability to elevate their privileges or gain insight on system jobs that run on the system. It is also a strategy to circumvent auditing controls.

PAM (Pluggable Authentication Modules) is a service that implements modular authentication modules on UNIX systems. It must be carefully configured to secure system authentication.

It is strongly recommended that sites abandon older clear-text protocols such as telnet, ftp, rlogin, rsh and rcp and use SSH to prevent session hijacking and sniffing of sensitive data off the network. If the ssh server is used, it must be carefully configured to prevent security issues.

#### SSH fingerprint

The section 9.13 affects SSH configuration. As a result of those configurations, the fingerprint of the SSH public key will be different on the next reboot of the system. This is normal behavior and you will be warned about the change of the fingerprint when you will try to connect to it again.

To remove old fingerprint you can use the following command :
`ssh-keygen -f "~/.ssh/known_hosts" -R {{ip_of_distant_system}}`

#### Ignoring errors for 9.3.13

The tasks 9.3.13.X check for allowed users and groups to connect on the system. We cannot define the allowed users without risking to lock the system. You can define the `AllowUsers`, `AllowGroups`, `DenyUsers` and `DenyGroups` to respect your current security rules.

### 10 - User Accounts and Environment

Setting up a secure defaults password policies for system, user accounts and their environment is a key point to secure servers. It is recommended to :

- be sure that any changes in /etc/login.defs file affect individual userIDs.
- make sure that accounts provided with Ubuntu that are used to manage applications and not used by regular users are
  locked to prevent them from being used to provide an interactive shell.
- use GID 0 for the root account helps prevent root-owned files from accidentally becoming accessible to non-privileged users.
- set a very secure default value for umask. This ensures that users, who creating files, make a conscious choice about their
  files permissions.

### 11 - Warning Banners

Warning messages inform users who are attempting to login to the system of their legal status regarding the system and must include the name of the organization that owns the system and any monitoring policies that are in place.
Login banners also has the side effect of providing detailed system and patch level informations to attackers attempting to target specific exploits at a system.

### 12 - Verify System File Permissions

This section specifically focus on critical configuration files for the servers security: /etc/passwd and /etc/shadow.

The /etc/passwd file is a text-based database of information about users that may log in to the system or other operating system user identities that own running processes, this file typically has file system permissions that allow it to be readable by all users of the system (world-readable), although it may only be modified by the superuser.

The /etc/shadow is used to increase the security level of passwords by restricting all but highly privileged users' access to hashed password data. Typically, that data is kept in files owned by and accessible only by the super user.

### 13 - Review User and Group Settings

Users and groups are used on Linux to control access to the system's files, directories, and peripherals. Linux offers relatively simple access control mechanisms by default, it recommended to enforce permissions for user and group.

## List of hardening audit tests

###
 1 - Patching and Software Updates

   -   1.1 Install Updates, Patches and Additional Security Software

###
 2 - Filesystem Configuration

   -   2.1 Create Separate Partition for /tmp
   -   2.2 Set nodev option for /tmp Partition
   -   2.3 Set nosuid option for /tmp Partition  
   -   2.4 Set noexec option for /tmp Partition
   -   2.5 Create Separate Partition for /var  
   -   2.6 Bind Mount the /var/tmp directory to /tmp  
   -   2.7 Create Separate Partition for /var/log  
   -   2.8 Create Separate Partition for /var/log/audit  
   -   2.9 Create Separate Partition for /home  
   -   2.10 Add nodev Option to /home  
   -   2.11 Add nodev Option to Removable Media Partitions  
   -   2.12 Add noexec Option to Removable Media Partitions  
   -   2.13 Add nosuid Option to Removable Media Partitions  
   -   2.14 Add nodev Option to /run/shm Partition
   -   2.15 Add noexec Option to /run/shm Partition  
   -   2.16 Add nosuid Option to /run/shm Partition
   -   2.17 Set Sticky Bit on All World-Writable Directories (preparation)  
   -   2.18 Disable Mounting of cramfs Filesystems  
   -   2.19 Disable Mounting of freevxfs Filesystems  
   -   2.20 Disable Mounting of jffs2 Filesystems  
   -   2.21 Disable Mounting of hfs Filesystems  
   -   2.22 Disable Mounting of hfsplus Filesystems  
   -   2.23 Disable Mounting of squashfs Filesystems  
   -   2.24 Disable Mounting of udf Filesystems  
   -   2.25 Disable Automounting  

###
 3 - Secure Boot Settings

   -   3 Check for /boot/grub/grub.cfg file
   -   3.1 Set User/Group Owner on bootloader config  
   -   3.2 Set Permissions on bootloader config  
   -   3.3.1 Set Boot Loader Superuser  
   -   3.3.2 Set Boot Loader Password  
   -   3.3.3 Disable password protection booting
   -   3.3.4 Update Grub configuration  
   -   3.4 Require Authentication for Single-User Mode  

###
 4 - Process Hardening

   -   4.1 Restrict Core Dumps  
   -   4.2 Enable XD/NX Support on 32-bit x86 Systems
   -   4.3 Enable Randomized Virtual Memory Region Placement  
   -   4.4 Disable Prelink
   -   4.5 Activate AppArmor

###
 5 - OS Services

   -   5.1 Ensure NIS is not installed  
   -   5.2 Ensure rsh, rlogin, rexec, talk, telnet, chargen, daytime, echo, discard, time is not enabled  
   -   5.3 Ensure rsh client is not installed
   -   5.4 Ensure talk server is not enabled
   -   5.5 Ensure talk client is not installed
   -   5.6 Ensure telnet server is not enabled
   -   5.7 Ensure tftp server is not enabled
   -   5.8 Ensure xinetd is not enabled

###
 6 - Special Purpose Services  

   -   6.1 Ensure the X Window system is not installed  
   -   6.2 Ensure Avahi Server is not enabled  
   -   6.3 Ensure print server is not enabled  
   -   6.4 Ensure DHCP Server is not enabled  
   -   6.5 Configure Network Time Protocol
   -   6.6 Ensure LDAP is not enabled  
   -   6.7 Ensure NFS and RPC are not enabled  
   -   6.8-14 Ensure DNS,FTP,HTTP,IMAP,POP,Samba,Proxy,SNMP Servers are not enabled  
   -   6.15 Configure Mail Transfer Agent for Local-Only Mode  
   -   6.16 Ensure rsync service is not enabled  
   -   6.17 Ensure Biosdevname is not enabled

###
 7 - Network Configuration and Firewalls

   -   7.1.1 Disable IP Forwarding  
   -   7.1.2 Disable Send Packet Redirects
   -   7.2 Modify Network Parameters (Host and Router)
   -   7.2.1 Disable Source Routed Packet Acceptance  
   -   7.2.2 Disable ICMP Redirect Acceptance  
   -   7.2.3 Disable Secure ICMP Redirect Acceptance  
   -   7.2.4 Log Suspicious Packets  
   -   7.2.5 Enable Ignore Broadcast Requests  
   -   7.2.6 Enable Bad Error Message Protection  
   -   7.2.7 Enable RFC-recommended Source Route Validation  
   -   7.2.8 Enable TCP SYN Cookies  
   -   7.3 Configure IPv6
   -   7.3.1 Disable IPv6 Router Advertisements  
   -   7.3.2 Disable IPv6 Redirect Acceptance  
   -   7.3.3 Disable IPv6  
   -    7.4.1 Install TCP Wrappers  
   -   7.4.2 Create /etc/hosts.allow  
   -   7.4.3 Verify Permissions on /etc/hosts.allow  
   -   7.4.4 Create /etc/hosts.deny  
   -   7.4.5 Verify Permissions on /etc/hosts.deny  
   -   7.5.1-4 Disable DCCP, SCTP, RDS, TIPC  
   -   7.6 Deactivate Wireless Interfaces  
   -   7.7 Ensure Firewall is active

###
 8 - Logging and Auditing

   -   8.1.1 Configure Data Retention
   -   8.1.2 Install and Enable auditd Service  
   -   8.1.3 Enable Auditing for Processes That Start Prior to auditd  
   -   8.1.4 Record Events That Modify Date and Time Information  
   -   8.1.5 Record Events That Modify User/Group Information  
   -   8.1.6 Record Events That Modify the System's Network Environment
   -   8.1.7 Record Events That Modify the System's Mandatory AccessControls  
   -   8.1.8 Collect Login and Logout Events  
   -   8.1.9 Collect Session Initiation Information  
   -   8.1.10 Collect Discretionary Access Control Permission ModificationEvents  
   -   8.1.11 Collect Unsuccessful Unauthorized Access Attempts to Files
   -   8.1.12 Collect Use of Privileged Commands  
   -   8.1.13 Collect Successful File System Mounts  
   -   8.1.14 Collect File Deletion Events by User  
   -   8.1.15 Collect Changes to System Administration Scope (sudoers)
   -   8.1.16 Collect System Administrator Actions (sudolog)  
   -   8.1.17 Collect Kernel Module Loading and Unloading  
   -   8.1.18 Make the Audit Configuration Immutable  
   -   8.2 Configure rsyslog
   -   8.2.1 Install the rsyslog package  
   -   8.2.2 Ensure the rsyslog Service is activated  
   -   8.2.3 Configure /etc/rsyslog.conf  
   -   8.2.4 Create and Set Permissions on rsyslog Log Files  
   -   8.2.5 Configure rsyslog to Send Logs to a Remote Log Host  
   -   8.2.6 Accept Remote rsyslog Messages Only on Designated Log Hosts  
   -   8.3.1 Install AIDE  
   -   8.3.2 Implement Periodic Execution of File Integrity  

###
 9 - System Access, Authentication and Authorization

   -   9.1.1.1 Check that cron conf file exists (check)  
   -   9.1.1.2 Enable cron Daemon  
   -   9.1.2 Set User/Group Owner and Permission on /etc/crontab  
   -   9.1.3 Set User/Group Owner and Permission on /etc/cron.hourly  
   -   9.1.4 Set User/Group Owner and Permission on /etc/cron.daily  
   -   9.1.5 Set User/Group Owner and Permission on /etc/cron.weekly
   -   9.1.6 Set User/Group Owner and Permission on /etc/cron.monthly
   -   9.1.7 Set User/Group Owner and Permission on /etc/cron.d  
   -   9.1.8 Restrict at/cron to Authorized Users  
   -   9.2.1 Set Password Creation Requirement Parameters Usingpam_cracklib  
   -   9.2.2 Set Lockout for Failed Password Attempts  
   -   9.2.3 Limit Password Reuse  
   -   9.3 Check if ssh is installed
   -   9.3.1 Set SSH Protocol to 2  
   -   9.3.2 Set LogLevel to INFO  
   -   9.3.3 Set Permissions on /etc/ssh/sshd_config  
   -   9.3.{4,7,8,9,10} Disable some SSH options  
   -   9.3.5 Set SSH MaxAuthTries to 4 or Less  
   -   9.3.6 Set SSH IgnoreRhosts to Yes  
   -   9.3.11 Use Only Approved Cipher in Counter Mode  
   -   9.3.12.1 Set Idle Timeout Interval for User Login  
   -   9.3.13.1 Limit Access via SSH  
   -   9.3.14 Set SSH Banner  
   -   9.3.14 Set SSH Banner File  
   -   9.4 Restrict root Login to System Console  
   -   9.5 Restrict Access to the su Command  

###
10 - User Accounts and Environment

   -   10.1.1 Set Password Expiration Days  
   -   10.1.2 Set Password Change Minimum Number of Days  
   -   10.1.3 Set Password Expiring Warning Days  
   -   10.2 Disable System Accounts  
   -   10.3 Set Default Group for root Account  
   -   10.4 Set Default umask for Users  
   -   10.5 Lock Inactive User Accounts  

###
11 - Warning Banners

   -   11.1 Set Warning Banner for Standard Login Services  
   -   11.2 Remove OS Information from Login Warning Banners  
   -   11.3 Set Graphical Warning Banner  

###
12 - Verify System File Permissions

   -   12.1 Verify Permissions on /etc/passwd  
   -   12.2 Verify Permissions on /etc/shadow  
   -   12.3 Verify Permissions on /etc/group  
   -   12.4 Verify User/Group Ownership on /etc/passwd  
   -   12.5 Verify User/Group Ownership on /etc/shadow  
   -   12.6 Verify User/Group Ownership on /etc/group  
   -   12.7 Find World Writable Files  
   -   12.8 Find Un-owned Files and Directories  
   -   12.9 Find Un-grouped Files and Directories  
   -   12.10 Find SUID System Executables  
   -   12.11 Find SGID System Executables  

###
13 - Review User and Group Settings

   -   13.1 Ensure Password Fields are Not Empty  
   -   13.2 Verify No Legacy "+" Entries Exist in /etc/passwd File  
   -   13.3 Verify No Legacy "+" Entries Exist in /etc/shadow File  
   -   13.4 Verify No Legacy "+" Entries Exist in /etc/group File  
   -   13.5 Verify No UID 0 Accounts Exist Other Than root  
   -   13.6 Ensure root PATH Integrity  
   -   13.7 Check Permissions on User Home Directories  
   -   13.8 Check User Dot File Permissions  
   -   13.9 Check Permissions on User .netrc Files  
   -   13.10 Check for Presence of User .rhosts Files  
   -   13.11 Check Groups in /etc/passwd  
   -   13.12 Check That Users Are Assigned Valid Home Directories  
   -   13.13 Check User Home Directory Ownership  
   -   13.14 Check for Duplicate UIDs  
   -   13.15 Check for Duplicate GIDs  
   -   13.16 Check for Duplicate User Names  
   -   13.17 Check for Duplicate Group Names  
   -   13.18 Check for Presence of User .netrc Files  
   -   13.19 Check for Presence of User .forward Files  
   -   13.20 Ensure shadow group is empty  
