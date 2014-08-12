#!/usr/bin/bash 
source config.cnf
set -e 


echo "---------------------------- Install and config NTP ----------------------------"
	apt-get install -y ntp

echo "---------------------------- Install Networking Node----------------------------"
	apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent openvswitch-datapath-dkms \
 	 neutron-l3-agent neutron-dhcp-agent -y 

echo "---------------------------- edit sysctl.conf ----------------------------"

	sed -i "s/#net.ipv4.conf.default.rp_filter=1/net.ipv4.conf.default.rp_filter=0/" /etc/sysctl.conf
	sed -i "s/#net.ipv4.conf.all.rp_filter=1/net.ipv4.conf.all.rp_filter=0/" /etc/sysctl.conf
	sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
	sysctl -p 	 

	if [[ ! -f /etc/neutron/neutron.conf.bak  ]]; then
		#statements
		cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.bak 
		echo "back up file neutron.conf"
	fi
echo "---------------------------- edit neutron.conf ----------------------------"
	sed -i "s/# auth_strategy = keystone/auth_strategy = keystone/" /etc/neutron/neutron.conf

	sed -i '/auth_host = 127.0.0.1/aauth_uri = http://HOST_NAME:5000/' /etc/neutron/neutron.conf
	sed -i 's|HOST_NAME|'$HOST_NAME'|' /etc/neutron/neutron.conf


	sed -i "s|auth_host = 127.0.0.1|auth_host = $HOST_NAME|" /etc/neutron/neutron.conf
	sed -i "s|admin_tenant_name = %SERVICE_TENANT_NAME%|admin_tenant_name = service|" /etc/neutron/neutron.conf
	sed -i "s|admin_user = %SERVICE_USER%|admin_user = neutron|" /etc/neutron/neutron.conf
	sed -i "s|admin_password = %SERVICE_PASSWORD%|admin_password = $NEUTRON_DBPASS|" /etc/neutron/neutron.conf

	echo " edit [keystone_authtoken] ---------------------------- done"

	sed -i "s|# rpc_backend = neutron.openstack.common.rpc.impl_kombu|rpc_backend = neutron.openstack.common.rpc.impl_kombu|" /etc/neutron/neutron.conf
	sed -i "s|# rabbit_host = localhost|rabbit_host = $HOST_NAME|" /etc/neutron/neutron.conf
	sed -i "s|# rabbit_password = guest|rabbit_password = $RABBIT_PASS|" /etc/neutron/neutron.conf

	echo " edit [rpc_backend ] ---------------------------- done"

	sed -i "s|core_plugin = neutron.plugins.ml2.plugin.Ml2Plugin|core_plugin = ml2|" /etc/neutron/neutron.conf
	sed -i "s|# service_plugins =|service_plugins = router|" /etc/neutron/neutron.conf
	sed -i "s|# allow_overlapping_ips = False|allow_overlapping_ips = True|" /etc/neutron/neutron.conf
	echo " edit [core_plugin ] ---------------------------- done"

	sed -i "s|# verbose = False|verbose = True|" /etc/neutron/neutron.conf

	echo " edit [turn on log ] ---------------------------- done"
echo "---------------------------- edit  /etc/neutron/l3_agent.ini ----------------------------"
	if [[ ! -f   /etc/neutron/l3_agent.ini.bak  ]]; then
		#statements
		cp   /etc/neutron/l3_agent.ini   /etc/neutron/l3_agent.ini.bak 
		echo "back up file   /etc/neutron/l3_agent.ini"
	fi

	sed -i "s|# interface_driver =|interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver|"  /etc/neutron/l3_agent.ini

	sed -i "s|# use_namespaces = True|use_namespaces = True|"  /etc/neutron/l3_agent.ini
	sed -i "s|# verbose = False|verbose = True|" /etc/neutron/l3_agent.ini

echo "---------------------------- edit /etc/neutron/dhcp_agent.ini ----------------------------"
	sed -i "s|# verbose = False|verbose = True|" /etc/neutron/dhcp_agent.ini
	sed -i "s|# interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver|interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver|" /etc/neutron/dhcp_agent.ini
	sed -i "s|# use_namespaces = True|use_namespaces = True|" /etc/neutron/dhcp_agent.ini
	sed -i "s|# dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq|dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq|" /etc/neutron/dhcp_agent.ini

echo "---------------------------- edit /etc/neutron/metadata_agent.ini ----------------------------"

	sed -i "s|auth_url = http://localhost:5000/v2.0|auth_url = http://controller:5000/v2.0|" /etc/neutron/metadata_agent.ini
	sed -i "s|auth_region = RegionOne|auth_region = regionOne|" /etc/neutron/metadata_agent.ini
	sed -i "s|admin_tenant_name = %SERVICE_TENANT_NAME%|admin_tenant_name = service|" /etc/neutron/metadata_agent.ini
	sed -i "s|admin_user = %SERVICE_USER%|admin_user = neutron|" /etc/neutron/metadata_agent.ini
	sed -i "s|admin_password = %SERVICE_PASSWORD%|admin_password = $NEUTRON_PASS|" /etc/neutron/metadata_agent.ini
	sed -i "s|# metadata_proxy_shared_secret =|metadata_proxy_shared_secret = $METADATA_SECRET|" /etc/neutron/metadata_agent.ini


echo "---------------------------- edit /etc/neutron/plugins/ml2/ml2_conf.ini ----------------------------"
	if [[ ! -f  /etc/neutron/plugins/ml2/ml2_conf.ini.bak  ]]; then
		#statements
		cp  /etc/neutron/plugins/ml2/ml2_conf.ini  /etc/neutron/plugins/ml2/ml2_conf.ini.bak 
		echo "back up file  /etc/neutron/plugins/ml2/ml2_conf.ini"
	fi

	
	sed -i "/# type_drivers = local,flat,vlan,gre,vxlan/a\type_drivers = gre\n\
	tenant_network_types = gre\n\
	mechanism_drivers = openvswitch" /etc/neutron/plugins/ml2/ml2_conf.ini
	echo " add ml2 ---------------------------- done"

	sed -i "s/# tunnel_id_ranges =/tunnel_id_ranges = 1:1000/" /etc/neutron/plugins/ml2/ml2_conf.ini
	echo " add ml2_type_gre ---------------------------- done"

	sed -i "/# Example: vxlan_group = 239.1.1.1/a\# add new ovs section\n\
	local_ip = $VM_IP_NETWORK\n\
	tunnel_type = gre\n\
	enable_tunneling = True" /etc/neutron/plugins/ml2/ml2_conf.ini

	echo " add ovesection ---------------------------- done"
	
	sed -i "s/# enable_security_group = True/enable_security_group = True/" /etc/neutron/plugins/ml2/ml2_conf.ini
	sed -i "/enable_security_group = True/afirewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver" /etc/neutron/plugins/ml2/ml2_conf.ini
	echo " add securitygroup ---------------------------- done"
echo "---------------------------- Restart openvswitch-switch----------------------------"
service openvswitch-switch restart

 ovs-vsctl add-br br-int

 ovs-vsctl add-br br-ex

ovs-vsctl add-port br-ex eth0

service neutron-plugin-openvswitch-agent restart
service neutron-l3-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart