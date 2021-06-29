#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo 'Please run as sudo or root user'
    exit
fi

node_exporter=y
if [ $node_exporter = y ]; then
    echo 'LOG: Installing Node Exporter'
	echo 'LOG: Installing Node Exporter'
	echo 'LOG: Download node exporter package, placed into /opt'
	cd /opt
	wget -q https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
	echo 'LOG: Extract node exporter'
	tar xfz node_exporter-0.18.1.linux-amd64.tar.gz
	cd node_exporter-0.18.1.linux-amd64
	
	echo 'Create node exporter service into /etc/systemd/system/node_exporter.service'
	cat > /etc/node_exporter.conf << EOF
ESYSTEMD="--collector.systemd"
EPROCESSES="--collector.processes"
ETCPSTAT="--collector.tcpstat"
EINTERRUPTS="--collector.interrupts"
EKSMD="--collector.ksmd"
EETHTOOL="--collector.ethtool"
EOF

	cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
[Service]
User=root
EnvironmentFile=/etc/node_exporter.conf
ExecStart=/opt/node_exporter-0.18.1.linux-amd64/node_exporter $ESYSTEMD $EPROCESSES $ETCPSTAT $EINTERRUPTS $EKSMD $EETHTOOL
[Install]
WantedBy=default.target
EOF

	echo 'LOG: enable and start node exporter service'
	systemctl daemon-reload
	systemctl enable node_exporter.service
	systemctl start node_exporter.service

	state=$(systemctl is-active node_exporter.service)
	ip_addr=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

	if [ $state = active ]; then
		    echo
		    echo '=================================='
		    echo 'NODE EXPORTER INSTALL SUCCESSFULLY' 
		    echo '=================================='
		    echo 
		    echo 'check node exporter metric: http://'$ip_addr':9100'
		    echo 
		else
		    echo
		    echo '============================'
		    echo 'NODE EXPORTER INSTALL FAILED' 
		    echo '============================'
		    echo
		fi
elif [ $node_exporter = n ]; then
    echo 'LOG: Node Exporter do not installed'
fi



ip_addr=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

echo 'LOG: Download prometheus packages, placed into /opt'
cd /opt
wget -q https://github.com/prometheus/prometheus/releases/download/v2.15.2/prometheus-2.15.2.linux-amd64.tar.gz

echo 'LOG: Extract prometheus packages'
tar xfz prometheus-2.15.2.linux-amd64.tar.gz
cd prometheus-2.15.2.linux-amd64

echo 'LOG: Create config.yml file'

job_name="node"
node_exporter_ip_addr="127.0.0.1"

cat > config.yml << EOF
global:
  scrape_interval:     15s
  evaluation_interval: 15s
scrape_configs:
  - job_name: 'prometheus-server'
    static_configs:
    - targets: ['$ip_addr:9090']
  - job_name: '$job_name'
    static_configs:
    - targets: ['$node_exporter_ip_addr:9100']
EOF

echo 'LOG: check config'
./promtool check config config.yml

echo 'LOG: create prometheus service into /etc/systemd/system/prometheus_server.service'
cat > /etc/systemd/system/prometheus_server.service << EOF
[Unit]
Description=Prometheus Server
[Service]
User=root
ExecStart=/opt/prometheus-2.15.2.linux-amd64/prometheus --config.file=/opt/prometheus-2.15.2.linux-amd64/config.yml --web.external-url=http://$ip_addr:9090/
[Install]
WantedBy=default.target
EOF

echo 'LOG: Enable and start prometheus service'

systemctl daemon-reload
systemctl enable prometheus_server.service
systemctl start prometheus_server.service

state=$(systemctl is-active prometheus_server.service)

if [ $state = active ]; then
    echo
    echo '==============================='
    echo 'PROMETHEUS INSTALL SUCCESSFULLY' 
    echo '==============================='
    echo 
    echo 'Prometheus dasboard : http://'$ip_addr':9090'
    if [ $node_exporter = y ]; then
        echo 'local node exporter : http://'$ip_addr':9100'
    fi
else
    echo
    echo '========================='
    echo 'PROMETHEUS INSTALL FAILED' 
    echo '========================='
    echo
fi

echo 'LOG: Download grafana packages, placed into /opt'
cd /opt
wget -q https://dl.grafana.com/oss/release/grafana-6.5.2.linux-amd64.tar.gz 

echo 'LOG: Extract grafana packages'
tar -zxf grafana-6.5.2.linux-amd64.tar.gz
cd grafana-6.5.2

echo 'LOG: Create grafana service into /etc/systemd/system/grafana.service'
cat > /etc/systemd/system/grafana.service << EOF
[Unit]
Description=Grafana
[Service]
User=root
ExecStart=/opt/grafana-6.5.2/bin/grafana-server -homepath /opt/grafana-6.5.2/ web
[Install]
WantedBy=default.target
EOF

echo 'LOG: Add Dashboard to Grafana'
cat > /opt/grafana-6.5.2/conf/provisioning/dashboards/dashboard.yml << EOF
apiVersion: 1

providers:
  - name: 'Prometheus'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 30
    allowUiUpdates: true
    editable: true
    jsonData:
      timeInterval: "5m"
    options:
      path: /opt/grafana-6.5.2/conf/provisioning/dashboards
EOF

cp /home/vagrant/grafanadashboard.json /opt/grafana-6.5.2/conf/provisioning/dashboards/grafanadashboard.json

echo 'LOG: Add datasource to Grafana'
cat > /opt/grafana-6.5.2/conf/provisioning/datasources/datasource.yml << EOF
# config file version
apiVersion: 1

# list of datasources that should be deleted from the database
deleteDatasources:
  - name: Prometheus-server
    orgId: 1

# list of datasources to insert/update depending
# whats available in the database
datasources:
  # <string, required> name of the datasource. Required
  - name: Prometheus-server
    # <string, required> datasource type. Required
    type: prometheus
    # <string, required> access mode. direct or proxy. Required
    access: proxy
    # <int> org id. will default to orgId 1 if not specified
    orgId: 1
    # <string> url
    url: http://127.0.0.1:9090
    # <string> database password, if used
    password:
    # <string> database user, if used
    user:
    # <string> database name, if used
    database:
    # <bool> enable/disable basic auth
    basicAuth: false
    # <string> basic auth username
    basicAuthUser: 
    # <string> basic auth password
    basicAuthPassword:
    # <bool> enable/disable with credentials headers
    withCredentials:
    # <bool> mark as default datasource. Max one per org
    isDefault: true
    # <map> fields that will be converted to json and stored in json_data
    jsonData:
      graphiteVersion: "1.1"
      tlsAuth: false
      tlsAuthWithCACert: false
    # <string> json object of data that will be encrypted.
    secureJsonData:
      tlsCACert: "..."
      tlsClientCert: "..."
      tlsClientKey: "..."
    version: 1
    # <bool> allow users to edit datasources from the UI.
    editable: true
EOF

echo 'LOG: Enable and start grafana service'
systemctl daemon-reload
systemctl enable grafana.service
systemctl start grafana.service

ip_addr=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
state=$(systemctl is-active grafana.service)

if [ $state = active ]; then
    echo
    echo '============================'
    echo 'GRAFANA INSTALL SUCCESSFULLY' 
    echo '============================'
    echo 
    echo 'Grafana dasboard : http://'$ip_addr':3000'
    echo 'default user     : admin'
    echo 'default passowrd : admin'
    echo
else
    echo
    echo '======================'
    echo 'GRAFANA INSTALL FAILED' 
    echo '======================'
    echo
fi


