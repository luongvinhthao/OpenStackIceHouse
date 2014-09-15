#! /bin/bash 
source config.cnf
set -e
echo "---------------------------- install neutron compute ----------------------------"
echo "---------------------------- edit sysctl.conf ----------------------------"

	sed -i "s/#net.ipv4.conf.default.rp_filter=1/net.ipv4.conf.default.rp_filter=0/" /etc/sysctl.conf
	sed -i "s/#net.ipv4.conf.all.rp_filter=1/net.ipv4.conf.all.rp_filter=0/" /etc/sysctl.conf
	sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/" /etc/sysctl.conf
	sysctl -p

echo "---------------------------- install neutron-plugin-ml2  ----------------------------"
	apt-get install neutron-common neutron-plugin-ml2 neutron-plugin-openvswitch-agent \
	  openvswitch-datapath-dkms -y

	if [[ ! -f /etc/neutron/neutron.conf.bak  ]]; then
		#statements
		cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.bak 
		echo "back up file neutron.conf"
	fi
echo "---------------------------- edit neutron.conf ----------------------------"
	sed -i "s|connection = sqlite:////var/lib/neutron/neutron.sqlite|connection = mysql://neutron:openstack12345@controller/neutron|" /etc/neutron/neutron.conf

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
	sed -i "s|# agent_down_time = 75|agent_down_time = 75|" /etc/neutron/neutron.conf
	sed -i "s|# report_interval = 30|report_interval = 5|" /etc/neutron/neutron.conf

	echo " edit [core_plugin ] ---------------------------- done"
		sed -i "s|# verbose = False|verbose = True|" /etc/neutron/neutron.conf


	echo " edit [turn on log ] ---------------------------- done"

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
	[ovs]\n\
	local_ip = $VM_IP_NETWORK\n\
	tunnel_type = gre\n\
	enable_tunneling = True" /etc/neutron/plugins/ml2/ml2_conf.ini

	echo " add ovesection ---------------------------- done"
	
	sed -i "s/# enable_security_group = True/enable_security_group = True/" /etc/neutron/plugins/ml2/ml2_conf.ini
	sed -i "/enable_security_group = True/afirewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver" /etc/neutron/plugins/ml2/ml2_conf.ini
	echo " add securitygroup ---------------------------- done"

echo "---------------------------- Restart the OVS service----------------------------"
service openvswitch-switch restart

echo "---------------------------- Add the integration bridge----------------------------"
#ovs-vsctl add-br br-int



echo "---------------------------- edit /etc/nova/nova.conf----------------------------"
	sed -i "/glance_host=controller/a\# add new line for neutron\n\
	neutron_url = http://controller:9696\n\
	neutron_auth_strategy = keystone\n\
	neutron_admin_tenant_name = service\n\
	network_api_class = nova.network.neutronv2.api.API\n\
	neutron_admin_username = neutron\n\
	neutron_admin_password = $NEUTRON_PASS\n\
	neutron_admin_auth_url = http://controller:35357/v2.0\n\
	linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver\n\
	firewall_driver = nova.virt.firewall.NoopFirewallDriver\n\
	security_group_api = neutron\n" /etc/nova/nova.conf

echo "---------------------------- Restart neutron service----------------------------"
service nova-compute restart
service neutron-plugin-openvswitch-agent restart
echo "---------------------------- finish----------------------------"