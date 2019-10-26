# Overview

Script that allows the easy creation of OpenVPN endpoints in any AWS region.  To create a VPN endpoint is done with a single command takes ~3 minutes. It will create the proper security groups. It spins up a tagged ec2  instance  and configures OpenVPN software. Once instance is configured an OpenVPN configuration file is downloaded and ready to use. There is also functionality to see which instances are running in which region and ability to terminate the instance when done. Additional functionality includes specifying instance type, generate ssh keypairs, specify custom ami,  change login user and more to come. 

[![asciicast](https://asciinema.org/a/102869.png)](https://asciinema.org/a/102869)

Use Case
  * Create on demand OpenVPN Endpoints in AWS that can easily be destroyed after done
    only pay for what you use.

## Dependencies

1. Create a virtualenv:
```
mkvirtualenv -p python3 env/
source env/bin/activate
````

2. Install dependencies by running `pip install -r requirements.txt`

3. Ensure that you have an AWS .credentials file by running: 
```
vi ~/.aws/credentials
```
Then type in the following and add your keys (remove parenthesis):
```
[default]
aws_access_key_id = (your_access_key_here)
aws_secret_access_key = (your_secret_key_here)
```
4. Install OpenVPN client (if needed)

## Installation

1. Ensure dependencies are all installed.
2. Clone repo to system.
```
git clone https://github.com/ttlequals0/autovpn.git
```
3. To create SSH keypair execute autovpn with -G and -r options for AWS region of choice. (optional)	
   NOTE: Make sure to add new key to your ssh-agent.
```
./autovpn -G -r us-east-1
```
4. Execute autovpn with -C -k and -r options to deploy to AWS:
```
./autovpn -C -r us-east-1 -k us-east-1_vpnkey
```
4. OpenVPN config files are downloaded to current working directory.
5. Import the OpenVPN config file and connect:
```
sudo openvpn us-east-1_aws_vpn.ovpn
```

## Man page
```
DESCRIPTION:
    autovpn - On Demand AWS OpenVPN Endpoint Deployment Tool.
	Project found at https://github.com/ttlequals0/autovpn
USAGE:
        ACTION	 [OPTIONS]
       -C    Create VPN endpoint.
       -D    Delete keypair from region.
       -G    Generate new keypair.
       -S    Get all running instances in a given region.
       -T    Terminate a OpenVPN endpoint.
       -d    Specify custom DNS server. (ex. 4.2.2.1)
       -h    Displays this message.
       -i    AWS Instance type (Optional, Default is t2.micro)
	     t2.nano t2.micro t2.small t2.medium t2.large.**
       -k    Specify the name of AWS keypair (Required)
       -m    Allow multiple connections to same endpoint.
       -r    Specify AWS Region (Required)
	     us-east-1 us-west-1 us-east-2 us-west-2 eu-west-1 eu-west-2
	     eu-west-3 eu-central-1 eu-north-1 ap-southeast-1 ap-northeast-1
	     ap-northeast-2 ap-northeast-3 ap-southeast-2 sa-east-1
       ap-east-1 ca-central-1 me-south-1
       -p    Specify custom OpenVPN UDP port
       -u    Specify custom ssh user.***
       -y    Skip confirmations
       -z    Specify instance id.
EXAMPLES:
  Create OpenVPN endpoint:
	autovpn -C -r us-east-1 -k us-east-1_vpnkey
  Generate keypair in a region.
	autovpn -G -r us-east-1
  Get running instances
	autovpn -S -r us-east-1
  Terminate OpenVPN endpoint
	autovpn -T -r us-east-1 -z i-b933e00c
  Using custom options
    autovpn -C -r us-east-1 -k us-east-1_vpnkey -a ami-fce3c696 -u ec2_user -i m3.medium
NOTES:
        * - Custom AMI may be needed if changing instance type.
        ** - Any instance size can be given but the t2.micro is more than enough.
        *** - Custom user might be need if using a custom ami.
	**** - AWS IAM user must have EC2 or Administrator permissions set.
```

## To Do
  * Continue to update documentation
  * Add deletion of Securoty Group if it is no longer in use.
  * Add ability to create more client configs for one endpoint.
  * Pull Requests are welcome.

