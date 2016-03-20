[![asciicast](https://asciinema.org/a/39964.png)](https://asciinema.org/a/39964)


This script assumes that all AWS credentials and tools are already setup on system.

1. Clone rep to system.
2. Execute autovpn with -k options to deploy to your default AWS region.
	./autovpn -k macbook
3. OpenVPN config files are downloaded to current working directory.
4. Import the OpenVPN config file into VPN client.
5. Connect to VPN.

<pre><code>
DESCRIPTION:
       	 autovpn - AWS OpenVPN Deployment Tool.
		 Project found at https://github.com/ttlequals0/autovpn
USAGE:
        ACTION	 [OPTIONS]
       -h	 Displays this message.
       -i	 AWS Instance type (Optional, Default is t2.micro)
			 t2.nano t2.micro t2.small t2.medium t2.large *
       -k	 Specify the name of AWS keypair (Required) **
       -r	 Specify AWS Region (Optional, will use default region)
			 us-east-1 us-west-1 us-west-2 eu-west-1 eu-west-1
			 ap-southeast-1 ap-northeast-1 ap-northeast-2 ap-southeast-2
			 sa-east-1 cn-north-1 ***
NOTES:
       	\* - In reality any instance size can be given but the t2.micro is more than 
       	 enough.
		\** - If you choose to deploy an endpoint in a different region make sure
		you have a keypair setup in that region.
		\*** - Since all ami's aren't located in all regions the ami being used will 
		need to  be changed to one that exists in that region. An option to do this 
		will be	added soon for now this will need to be manually changed in python 
		script.
</pre></code>
