[![asciicast](https://asciinema.org/a/40608.png)](https://asciinema.org/a/40608)


Dependencies: Boto and aws .credentials file on system
	


1. Clone repo to system.
2. Execute autovpn with -C -k and -r options to deploy to AWS
	`./autovpn -C -r us-east-1 -k macbook`
3. OpenVPN config files are downloaded to current working directory.
4. Import the OpenVPN config file into VPN client.
5. Connect to VPN.

<pre><code>
DESCRIPTION:
       	 autovpn - AWS OpenVPN Deployment Tool.
		 Project found at https://github.com/ttlequals0/autovpn
USAGE:
        ACTION	 [OPTIONS]
       -C    Create VPN endpoint.
       -G	 Generate new keypair.
       -S	 Get all running instances in a given region.
       -T	 Terminate a OpenVPN endpoint. 
       -a    Specify custom ami.*             
       -h	 Displays this message.
       -i	 AWS Instance type (Optional, Default is t2.micro)
			 t2.nano t2.micro t2.small t2.medium t2.large.**
       -k	 Specify the name of AWS keypair (Required)
       -r	 Specify AWS Region (Required)
			 us-east-1 us-west-1 us-west-2 eu-west-1 eu-central-1
			 ap-southeast-1 ap-northeast-1 ap-northeast-2 ap-southeast-2
			 sa-east-1 
       -u  	 Specify custom ssh user.***      
       -z	 Specify instance id.	 
EXAMPLES:
  Create OpenVPN endpoint:
	autovpn -C -r us-east-1 -k macbook
  Generate keypar in a region.
	autovpn -G -r us-east-1
  Get running instances
	autovpn -S -r us-west-1
  Terminate OpenVPN endpoint
	autovpn -T -r us-west-1 -z i-b933e00c
  Using custom options
    autovpn -C -r us-east-1 -k macbook -a ami-fce3c696 -u ec2_user -i m3.medium
NOTES:
        \* - Customs ami may be needed if changing instance type.
       	\** - In reality any instance size can be given but the t2.micro is more than 
       	 enough.
        \*** - Custom user might be need if using a custom ami.        

</pre></code>
