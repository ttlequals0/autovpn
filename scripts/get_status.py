import boto
import boto.ec2
import sys

region = sys.argv[1]
tag_name = "auto_vpn"
group_name = "vpn_2"


conn_region = boto.ec2.connect_to_region(region)


def get_status():

    ec2 = conn_region
    reservations = ec2.get_all_instances(
        filters={'instance-state-name': 'running'})
    instances = [i for r in reservations for i in r.instances]

    for instance in instances:
        if instance.__dict__['tags'].__dict__['_current_key'] == tag_name:
            instanceip = instance.__dict__['ip_address']
            print("%s \tIP:%s" % (instance, instanceip))


if __name__ == "__main__":
    get_status()
