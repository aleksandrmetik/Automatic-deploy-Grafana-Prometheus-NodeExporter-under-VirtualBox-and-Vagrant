#!/bin/bash

detect_os () {

	echo -e "=========== Detecting distribution and release ... ==========="
	if [ -e /etc/os-release ]; then
	    source /etc/os-release
	    echo "Distribution id: $ID"
	    echo "Distribution release id: $VERSION_ID"
	    echo "Distribution description: $PRETTY_NAME"
	else
	    ID=unknown
	    VERSION_ID=unknown
	    PRETTY_NAME="Unknown distribution and release"
	    echo "LOG WARNING: /etc/os-release configuration not found. Unable to detect distribution." >&2
	    if [ -z "$dist" -o -z "$code" ]; then
	        echo "LOG ERROR: One or both of --distribution and --release options were not specified." >&2
	        echo "This is an unsupported distribution and/or version!" >&2
	        exit 1
	    fi
	fi

	# Check --distribution parameter.
	if [ -n "$dist" ]; then
	    dist=${dist,,}
	    echo "Checking --distribution \"$dist\" to ensure it has a sane value."
	    # If $ID detected above does not match parameter, then do some checking
	    if [ "$dist" != "$ID" ]; then
	        echo "Detected distribution \"$ID\" does not match specified one of \"$dist\". Checking ..."
	        case "$dist" in
	            centos|rhel)   pkg_installer=/usr/bin/yum; echo "Detected yum package installer" ;;
	            debian|ubuntu) pkg_installer=/usr/bin/apt-get; echo "Detected apt-get package installer" ;;
	            *) echo "LOG ERROR: the value \"$dist\" specified for --distribution is unsupported." >&2
	               exit 1
	               ;;
	        esac
	        if [ ! -x "$pkg_installer" ]; then
	            echo "LOG ERROR: The value \"$dist\" specified for --distribution does not appear compatible!" >&2
	            exit 1
	        fi
	    fi
	fi

	# Validate the distribution and release is a supported one; set boolean flags.
	is_debian_dist=false
	is_debian_buster=false
	is_debian_stretch=false
	is_ubuntu_dist=false
	is_ubuntu_hirsute=false
	is_ubuntu_groovy=false
	is_ubuntu_focal=false
	is_ubuntu_bionic=false
	is_ubuntu_xenial=false
	is_centos_dist=false
	is_centos_6=false
	is_centos_7=false
	is_centos_8=false
	# Use specified distribution and release or detected otherwise.
	dist="${dist:-$ID}"
	code="${code:-$VERSION_ID}"
	code="${code,,}"
	echo "Validating dist-code: ${dist}-${code}"
	case "${dist}-${code}" in
	    ubuntu-21.04)
	        code="hirsute"
	        is_ubuntu_dist=true
	        is_ubuntu_hirsute=true
	        ;;
	    ubuntu-20.10)
	        code="groovy"
	        is_ubuntu_dist=true
	        is_ubuntu_groovy=true
	        ;;
	    ubuntu-20.04)
	        code="focal"
	        is_ubuntu_dist=true
	        is_ubuntu_focal=true
	        ;;
	    ubuntu-18.04)
	        code="bionic"
	        is_ubuntu_dist=true
	        is_ubuntu_bionic=true
	        ;;
	    ubuntu-16.04|ubuntu-xenial|ubuntu-xenial_docker_minimal)
	        code="xenial"
	        is_ubuntu_dist=true
	        is_ubuntu_xenial=true
	        ;;
	    ubuntu-14.04|ubuntu-trusty)
	        echo -e "LOG ERROR: Ubuntu Trusty is not supported" >&2
	        exit 1
	        ;;
	    debian-9|debian-stretch)
	        code="stretch"
	        is_debian_dist=true
	        is_debian_stretch=true
	        ;;
	    debian-10|debian-buster)
	        code="buster"
	        is_debian_dist=true
	        is_debian_buster=true
	        ;;
	    #Fix for Raspbian 9 (stretch)
	    raspbian-9|9)
		code="stretch"
		dist="debian"
		is_debian_dist=true
		is_debian_stretch=true
		;;
	    #End of fix
	    #Fix for Raspbian 10 (buster)
	    raspbian-10|10)
	        code="buster"
	        dist="debian"
	        is_debian_dist=true
	        is_debian_buster=true
	        ;;
	    #End of fix
	    debian-8|debian-jessie)
	        echo -e "LOG ERROR: Debian Jessie is not supported" >&2
	        exit 1
	        ;;
	    debian-7|debian-wheezy)
	        echo -e "LOG ERROR: Debian Wheezy is not supported" >&2
	        exit 1
	        ;;
	    centos-8)
	        is_centos_dist=true
	        is_centos_8=true
	        ;;
	    centos-7)
	        is_centos_dist=true
	        is_centos_7=true
	        ;;
	    centos-6)
	        is_centos_dist=true
	        is_centos_6=true
	        ;;
	    *)
	        echo -e "LOG ERROR: Distribution \"$PRETTY_NAME\" is not supported with \"${dist}-${code}\"!" >&2
	        exit 1
	        ;;
	esac
	echo "Using distribution id \"$dist\", release code \"$code\""
}

install_virtualbox_and_vagrant () {
	echo -e "=========== Installing VirtualBox, Vagrant and dependencies ... ==========="
	if $is_debian_dist; then
		sudo apt-get -qq update
		sudo apt-get -qq install  wget curl
		wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
		wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
		wget -q https://apt.releases.hashicorp.com/gpg -O- | sudo apt-key add -
		sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
		sudo apt-add-repository "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
		sudo apt-get -qq update
		sudo apt-get -qq install virtualbox-6.1 vagrant
	elif $is_ubuntu_dist; then
		sudo apt-get -qq update
		sudo apt-get -qq install  wget curl
		wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
		wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
		wget -q https://apt.releases.hashicorp.com/gpg -O- | sudo apt-key add -
		sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
		sudo apt-add-repository "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian $(lsb_release -cs) contrib"
		sudo apt-get -qq update
		sudo apt-get -qq install virtualbox-6.1 vagrant
	elif $is_centos_dist; then
		sudo yum update
		sudo yum install –qq patch gcc kernel-headers kernel-devel make perl wget curl fontforge binutils glibc-headers glibc-devel yum-utils
		sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
		sudo yum -y install vagrant
	elif $is_centos_6; then
		sudo wget http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -P /etc/yum.repos.d
		sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
		export KERN_DIR=/usr/src/kernels/`uname -r`
		sudo yum install VirtualBox-6.1 
		sudo service vboxdrv setup
	elif $is_centos_7; then
		sudo wget http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -P /etc/yum.repos.d
		sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
		export KERN_DIR=/usr/src/kernels/`uname -r`
		sudo yum install VirtualBox-6.1
		sudo /usr/lib/virtualbox/vboxdrv.sh setup
		sudo service vboxdrv setup
	elif $is_centos_8; then
		sudo dnf makecache
		sudo dnf upgrade
		sudo dnf config-manager --add-repo=https://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo
		sudo dnf install VirtualBox-6.1 -y
#		sudo wget http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo -P /etc/yum.repos.d
#		sudo yum install VirtualBox-6.1
#		sudo /usr/lib/virtualbox/vboxdrv.sh setup
#		sudo service vboxdrv setup
	fi
}

configure_vagrant () {
	echo "=========== Configuring vagrant ==========="
	vagrant plugin install vagrant-vbguest
	vagrant box add ubuntu/bionic64
	vagrant init ubuntu/bionic64
	hostip="0.0.0.0"
	grep -qxF '  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "'$hostip'"' Vagrantfile || echo '  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "'$hostip'"' >> Vagrantfile
	grep -qxF '  config.vm.network "forwarded_port", guest: 9000, host: 9000, host_ip: "'$hostip'"' Vagrantfile || echo '  config.vm.network "forwarded_port", guest: 9000, host: 9000, host_ip: "'$hostip'"' >> Vagrantfile
	grep -qxF '  config.vm.network "forwarded_port", guest: 9090, host: 9090, host_ip: "'$hostip'"' Vagrantfile || echo '  config.vm.network "forwarded_port", guest: 9090, host: 9090, host_ip: "'$hostip'"' >> Vagrantfile
	grep -qxF '  config.vm.network "forwarded_port", guest: 9090, host: 9090, host_ip: "'$hostip'"' Vagrantfile || echo '  config.vm.network "forwarded_port", guest: 9100, host: 9100, host_ip: "'$hostip'"' >> Vagrantfile
	grep -qxF '  config.vm.provision "file", source: "grafanadashboard.json", destination: "$HOME/grafanadashboard.json"' Vagrantfile || echo '  config.vm.provision "file", source: "grafanadashboard.json", destination: "$HOME/grafanadashboard.json"' >> Vagrantfile
	grep -qxF '  config.vm.provision "shell", path: "deploy.sh"' Vagrantfile || echo '  config.vm.provision "shell", path: "deploy.sh"' >> Vagrantfile
	sed  -e "/end/d" -i Vagrantfile
	echo "end" >> Vagrantfile
}

start_vb () {
	echo "=========== Starting VB and Vagrant ==========="
	vagrant up
	}

detect_os
install_virtualbox_and_vagrant
configure_vagrant
start_vb
