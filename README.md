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

## How do deploy:
git clone https://github.com/aleksandrmetik/Automatic-deploy-Grafana-Prometheus-NodeExporter-under-VirtualBox-and-Vagrant
sudo su
./install.sh
