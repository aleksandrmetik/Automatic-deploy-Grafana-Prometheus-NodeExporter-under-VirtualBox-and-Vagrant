# Automatic deploy Grafana Prometheus NodeExporter under VirtualBox/Vagrant
## What is it?
* This is a set of bash scripts to automatically install VirtualBox 6.1, Vagrant and create ubuntu/bionic guest with automatic deployment of Prometheus, Grafana and NodeExporter.
* Grafana automatically gets through Provisioning dashboard "grafanadashboard.json"
* How it looks in the end you can see in the PDF file "example of grafana dashboard.pdf"
* Script was written for Ubuntu, Debian, CentOs
**IMPORTANT!!! DO NOT USE IN PRODUCTION environment!**

## Information about tested OS and combinations of Hardware and Hypervisors 
 Tested OS:
 + Ubuntu 20.04
 + Ubuntu 18.04

 Tested hardware and hypervisors:
 Works:
 + Intel Xeon E5-4650, Linux 5.4.78-2-pve, Proxmox Hypervisor <-> QEMU  VirtualBox (Nested Virt) 

 Doesn't work: 
 - AMD Ryzen 7 3700X (Hetzner dedicated), Linux 5.4.119-1-pve,  PVE Hypervisor <-> QEMU VirtualBox (Nested virtualization)
   Stuck, hang during bootload linux kernel under VB guest. Tried to change a lot of options of virtualization on both sides PVE and VB but unsuccessful..

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

