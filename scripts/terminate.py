import boto
import boto.ec2
import sys

region = sys.argv[1]
instances = sys.argv[2]


conn_region = boto.ec2.connect_to_region(region)


def ec2_terminate():

    ec2 = conn_region

    ec2.terminate_instances(instance_ids=[instances])
    print("Success")


if __name__ == "__main__":
    ec2_terminate()
