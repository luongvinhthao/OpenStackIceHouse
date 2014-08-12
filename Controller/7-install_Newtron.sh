#!/bin/bash
source config.cnf
set -e
echo "---------------------------- Install Neutron----------------------------"
	if [[ ! -f /etc/neutron/neutron.conf.bak ]]; then
		#statements
		cp /etc/neutron/neutron.conf /etc/neutron/neutron.conf.bak
	fi

echo "---------------------------- edit neutron.conf----------------------------"
	sed -i "s|connection = sqlite:////var/lib/neutron/neutron.sqlite|connection = mysql://neutron:$NEUTRON_DBPASS@$HOST_NAME/neutron|" /etc/neutron/neutron.conf
	sed -i "s|# auth_strategy = keystone|auth_strategy = keystone|" /etc/neutron/neutron.conf
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

	sed -i "s|# notify_nova_on_port_status_changes = True|notify_nova_on_port_status_changes = True|" /etc/neutron/neutron.conf
	sed -i "s|# notify_nova_on_port_data_changes = True|notify_nova_on_port_data_changes = True|" /etc/neutron/neutron.conf
	sed -i "s|# nova_url = http://127.0.0.1:8774/v2|nova_url = http://$HOST_NAME:8774/v2|" /etc/neutron/neutron.conf
	sed -i "s|# nova_admin_username =|nova_admin_username = nova|" /etc/neutron/neutron.conf

	sed -i "s|# nova_admin_tenant_id =|nova_admin_tenant_id = $(keystone service-list | awk '/ network / {print $2}')|" /etc/neutron/neutron.conf
	sed -i "s|# nova_admin_password =|nova_admin_password = $NOVA_PASS|" /etc/neutron/neutron.conf
	sed -i "s|# nova_admin_auth_url =|nova_admin_auth_url = http://$HOST_NAME:35357/v2.0|" /etc/neutron/neutron.conf


	sed -i "s|core_plugin = neutron.plugins.ml2.plugin.Ml2Plugin|core_plugin = ml2|" /etc/neutron/neutron.conf
	sed -i "s|# service_plugins =|service_plugins = router|" /etc/neutron/neutron.conf
	sed -i "s|# allow_overlapping_ips = False|allow_overlapping_ips = True|" /etc/neutron/neutron.conf

	echo " edit [core_plugin ] ---------------------------- done"
	sed -i "s|# verbose = False|verbose = True|" /etc/neutron/neutron.conf

	echo " edit [turn on log ] ---------------------------- done"

echo "---------------------------- edit /etc/neutron/plugins/ml2/ml2_conf.ini----------------------------"
	if [[ ! -f /etc/neutron/plugins/ml2/ml2_conf.ini.bak ]]; then
		#statements
		cp /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini.bak
		echo "back up file ml2_conf.ini ------------------------------------------"
	fi
	sed -i "/# type_drivers = local,flat,vlan,gre,vxlan/a\type_drivers = gre\n\
	tenant_network_types = gre\n\
	mechanism_drivers = openvswitch" /etc/neutron/plugins/ml2/ml2_conf.ini

	echo " add ml2 ---------------------------- done"

	sed -i "s/# tunnel_id_ranges =/tunnel_id_ranges = 1:1000/" /etc/neutron/plugins/ml2/ml2_conf.ini
	echo " add ml2_type_gre ---------------------------- done"

	sed -i "s/# enable_security_group = True/enable_security_group = True/" /etc/neutron/plugins/ml2/ml2_conf.ini
	sed -i "/enable_security_group = True/afirewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver" /etc/neutron/plugins/ml2/ml2_conf.ini
echo "---------------------------- edit /etc/nova/nova.conf----------------------------"
	sed -i "/auth_strategy = keystone/a\neutron_url = http://controller:9696\n\
	neutron_auth_strategy = keystone\n\
	neutron_admin_tenant_name = service\n\
	network_api_class = nova.network.neutronv2.api.API\n\
	neutron_admin_username = neutron\n\
	neutron_admin_password = $NEUTRON_PASS\n\
	neutron_admin_auth_url = http://controller:35357/v2.0\n\
	linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver\n\
	firewall_driver = nova.virt.firewall.NoopFirewallDriver\n\
	security_group_api = neutron\n\
	service_neutron_metadata_proxy = true\n\
	neutron_metadata_proxy_shared_secret = $METADATA_SECRET" /etc/nova/nova.conf


echo "---------------------------- Restart nova-api service----------------------------"
service nova-api restart
echo "---------------------------- Finish----------------------------"