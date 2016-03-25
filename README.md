This script assumes that all AWS credentials and tools are already setup on system.

1. Clone rep to system.
2. Execute autovpn with -C -k and -r options to deploy to AWS
	./autovpn -C -r us-east-1 -k macbook
3. OpenVPN config files are downloaded to current working directory.
4. Import the OpenVPN config file into VPN client.
5. Connect to VPN.

<pre><code>
DESCRIPTION:
       	 autovpn - AWS OpenVPN Deployment Tool.
		 Project found at https://github.com/ttlequals0/autovpn
USAGE:
        ACTION	 [OPTIONS]
       -C   Create VPN endpoint.
       -h	 Displays this message.
       -i	 AWS Instance type (Optional, Default is t2.micro)
			 t2.nano t2.micro t2.small t2.medium t2.large *
       -k	 Specify the name of AWS keypair (Required) **
       -r	 Specify AWS Region (Required)
			 us-east-1 us-west-1 us-west-2 eu-west-1 eu-central-1
			 ap-southeast-1 ap-northeast-1 ap-northeast-2 ap-southeast-2
			 sa-east-1 
NOTES:
       	\* - In reality any instance size can be given but the t2.micro is more than 
       	 enough.
		\** - If you choose to deploy an endpoint in a different region make sure
		you have a keypair setup in that region.
</pre></code>
