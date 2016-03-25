import time
import boto
import boto.ec2
import boto.manage.cmdshell
import sys

keyname=sys.argv[1]
instance_type=sys.argv[2]
region=sys.argv[3]
ami=sys.argv[4]

if region:
    conn_region = boto.ec2.connect_to_region(region)
else:
    conn_region = boto.connect_ec2()

def auto_vpn(ami=ami,
                    instance_type=instance_type,
                    key_name=keyname,
                   	group_name="vpn_2",
                    ssh_port="22",
                    vpn_port="1194",
                    cidr="0.0.0.0/0",
                    tag="auto_vpn",
                    user_data=None,
                    cmd_shell=True,
                    login_user="ec2-user"):
	

	ec2 = conn_region 
 
	try:
    		group = ec2.get_all_security_groups(groupnames=[group_name])[0]
	except ec2.ResponseError, e:
    		if e.code == 'InvalidGroup.NotFound':
        		"""print'Creating security group %s' % group_name"""
        		group = ec2.create_security_group(group_name,
                                                'A group that allows VPN access')
    		else:
        		raise
	try:
    		group.authorize('tcp',ssh_port,ssh_port,cidr)
    		group.authorize('udp',vpn_port,vpn_port,cidr)

	except ec2.ResponseError, e:
    		if e.code == 'InvalidPermission.Duplicate':
        		"""print ('Security group %s already exists') % group_name"""
    		else:
        		raise
	reservation = ec2.run_instances(ami,
    	key_name=key_name,
    	security_groups=[group_name],
    	instance_type=instance_type,
    	user_data=user_data)

	instance = reservation.instances[0]
	while instance.state != 'running':
    		time.sleep(30)
    		instance.update()

        instance.add_tag(tag)

        global host
        host = instance.ip_address
        print "%s" % host
	

if __name__ == "__main__": 
    auto_vpn()