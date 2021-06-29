# Automatic deploy Grafana Prometheus NodeExporter under VirtualBox/Vagrant

## Information about tested OS and combination of Hardware and Hypervisors 
 Tested OS:
 + Ubuntu 20.04

 Tested hardware and hypervisors:
 Works:
 + Intel Xeon E5-4650, Linux 5.4.78-2-pve, Proxmox Hypervisor <-> QEMU  VirtualBox (Nested Virt) 

 Doesn't work: 
 - AMD Ryzen 7 3700X (Hetzner dedicated), Linux 5.4.119-1-pve,  PVE Hypervisor <-> QEMU VirtualBox (Nested virtualization)
   Stuck, hang during bootload linux kernel under VB guest. Tried to change a lot of options of virtualization on both sides PVE and VB but unsucceful.

## How to install:
```bash
sudo apt-get update -qq && sudo apt-get install git -yqq
git clone https://github.com/aleksandrmetik/Some-test-activities
cd Some-test-activities/
./install.sh
```
After installation, the following resources should be available:
  Grafana http://<host-ip>:3000
  Prometheus http://<host-ip>:9090
  Node Exporter http://<host-ip>:9100
