# Automatic deploy Grafana Prometheus NodeExporter under VirtualBox/Vagrant

**IMPORTANT!!! DO NOT USE IN PRODUCTION environment!**

## What is it?
* This is a set of bash scripts to automatically install VirtualBox 6.1, Vagrant and create ubuntu/bionic guest with automatic deployment of Prometheus, Grafana and NodeExporter.
* Grafana automatically gets through Provisioning dashboard "grafanadashboard.json"
* How it looks in the end you can see in the PDF file "example of grafana dashboard.pdf"
* Script was written for Ubuntu, Debian, CentOs
* This script is not immutable, external dependencies can be changed by a third party (VirtualBox, Vagrant, Apt repositories and etc)

## What is this script for?
* This script is needed to demonstrate the capabilities of automated deployment using Bash.
* Of course, the option through Docker is much more convenient and faster.
( You may also find that using KVM/QEMU on servers without a GUI will be easier than VirtualBox.
* How can this script be useful? When developers use Docker on their workstations, they may encounter a number of problems:
  * Docker gradually eats up all available space in host. VirtualBox will more strictly limit disk, RAM and CPU consumption within the given limits;
  * Conflicts when they need to deploy multiple instances of the same project (port conflicts, same containers names and etc) or a lot of differences projects;
  * Docker is less secure than kernel-based virtualization;
  * You can deliver ready-to-use environment for your team's members by OVF format;
  * VirtualBox is able to snapshot, it will be easier for you to revert to a previous state of a VM;
  * You can run Docker inside VirtualBox VM, but nested virtualization is needed here;
  * Clearing out old projects is much easier, just delete the entire virtual machine. If you may need the VM in the future, export it before.
So, You can make up 100500 reasons for this, but this is just an example.

## Information about tested OS and combinations of Hardware and Hypervisors 
 Tested OS:
 + Ubuntu 20.04
 + Ubuntu 18.04

Tested hardware and hypervisors:
* Works:
  * Intel Xeon E5-4650, Linux 5.4.78-2-pve, Proxmox Hypervisor <-> QEMU  VirtualBox (Nested Virt) 

* Doesn't work: 
  * AMD Ryzen 7 3700X (Hetzner dedicated), Linux 5.4.119-1-pve,  PVE Hypervisor <-> QEMU VirtualBox (Nested virtualization). Stuck, hang during bootload linux kernel under VB guest. Tried to change a lot of options of virtualization on both sides PVE and VB but unsuccessful..

## How to install:
# Ubuntu/Debian
```bash
sudo apt-get update -qq && sudo apt-get install git -yqq
git clone https://github.com/aleksandrmetik/Some-test-activities
cd Some-test-activities/
./install.sh
```
# Centos
```bash
sudo yum update -qq && sudo yum install git -yqq
git clone https://github.com/aleksandrmetik/Some-test-activities
cd Some-test-activities/
./install.sh
```

After installation, the following resources should be available by **Forwarding ports** from VirtualBox Guest to Host instance:
* Grafana http://%host-ip%:3000
* Prometheus http://%host-ip%:9090
* Node Exporter http://%host-ip%:9100

Default Grafana credential: 
* Login: admin
* Password: admin

