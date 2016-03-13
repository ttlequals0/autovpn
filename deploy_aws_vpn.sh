#!/bin/bash

ssh_options="-o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=1 -o ConnectTimeout=30 -t -t "
user='ubuntu'
get_script="wget http://git.io/vWVpZ --no-check-certificate -O openvpn-autoinstall.sh"
run_script="sudo bash ./openvpn-autoinstall.sh"
remote_path="\$HOME/aws_vpn.ovpn"
local_path="$HOME/Downloads"


bail ()
{
	echo "something failed"
	exit ${1:="1"}
}

echo "Creating ec2 instance. This will take a few minutes..."
instance_ip=$(python create_ec2.py)
[[ $instance_ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] || bail 2
echo "Instance has been created $instance_ip"
echo "Giving new instance some time to fully boot up...."
while [ "$status" != "0" ] 
do 
	echo "$instance_ip is still booting.."
	sleep 15
	ssh-keyscan $instance_ip 2>&1 | grep -v "^$" > /dev/null
	status=$?
done

echo "Setting up VPN on $instance_ip"
ssh $ssh_options "$user"@$instance_ip "$get_script && $run_script" 
scp $user@$instance_ip:"$remote_path" "$local_path" 
echo "aws_vpn.ovpn file is located at ~/Downloads"