import os
import time
import boto
import boto.manage.cmdshell
import paramiko

def auto_vpn(ami="ami-d05e75b8",
                    instance_type="t2.micro",
                    key_name="macbook",
                    key_dir="~/.ssh",
                   	group_name="vpn_2",
                    ssh_port="22",
                    vpn_port="1194",
                    cidr="0.0.0.0/0",
                    tag="auto_vpn",
                    user_data=None,
                    cmd_shell=True,
                    login_user="ec2-user"):
	

	ec2 = boto.connect_ec2()  
 
	try:
    		group = ec2.get_all_security_groups(groupnames=[group_name])[0]
	except ec2.ResponseError, e:
    		if e.code == 'InvalidGroup.NotFound':
        		print'Creating security group %s' % group_name
        		group = ec2.create_security_group(group_name,
                                                'A group that allows VPN access')
    		else:
        		raise
	try:
    		group.authorize('tcp',ssh_port,ssh_port,cidr)
    		group.authorize('udp',vpn_port,vpn_port,cidr)

	except ec2.ResponseError, e:
    		if e.code == 'InvalidPermission.Duplicate':
        		print ('Security group %s already exists') % group_name
    		else:
        		raise
	reservation = ec2.run_instances(ami,
    	key_name=key_name,
    	security_groups=[group_name],
    	instance_type=instance_type,
    	user_data=user_data)

	instance = reservation.instances[0]
	print 'waiting for instance...'
	while instance.state != 'running':
    		time.sleep(30)
    		instance.update()
    		print 'Instance is now running'
    		print 'Instance IP is %s' % instance.ip_address
    		instance.add_tag(tag)

        host = instance.ip_address
        program = "wget http://git.io/vWVpZ --no-check-certificate -O openvpn-autoinstall.sh; sudo bash openvpn-autoinstall.sh"
    	
    	time.sleep(30)  
	print "Establishing SSH connection to: %s" % host
	ssh = paramiko.SSHClient()
	ssh.set_missing_host_key_policy(
    	paramiko.AutoAddPolicy())
	ssh.load_system_host_keys()
	ssh.connect("%s" % host, username="ubuntu")
	stdin, stdout, stderr = ssh.exec_command('%s' % program)

	print "stderr: ", stderr.readlines()
	print "pwd: ", stdout.readlines()

	localpath="~/Downloads"
	remotepath="~/aws_vpn.ovpn"

	os.system("scp ubuntu@%s:%s %s") % host, remotepath, localpath

	print "aws_vpn.ovpn file is located at ~/Downloads"

	return (instance)

if __name__ == "__main__":
	auto_vpn()