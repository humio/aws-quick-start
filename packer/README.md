Note, this repository is **Work In Progress!**

# Humio - AWS AMI

The AWS AMI is built using [Hashicorp Packer](https://www.packer.io/).  

## Prerequisites

You should ensure that the following are in place:

- Install [Packer](https://www.packer.io/downloads.html) (> version 1.2.3)
- Install [Ansible](http://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) (> version 2.5)
- Install the [AWS CLI]()
- [Configure AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) in your local environment - using either environment variables, the AWS credentials file or the CLI credentials file - so that Packer can connect to the AWS API

## Creating the AWS AMI

To build the AMI run:

`packer build packer.json`

This will create an AMI in your AWS account. At present this is hardcoded to eu-west-2 but will be upgraded shortly to use a parameterised region.




## Running the AWS API

You can run the AWS AMI by launching it through the AWS console. 

You must use at least a t2.medium (or other instance type with at least 2Gb RAM). Choosing the right instance size depends on your ingest volume and usage patterns. As a general guideline the following table is a starting point for sizing your Humio instance.

- Up to 5 GB/day: m4.medium
- Up to 15 GB/day: m4.large
- Up to 35 GB/day: m4.xlarge
- Up to 75 GB/day: m4.2xlarge
- Up to 150 GB/day: m4.4xlarge

You will also be presented with the option to create 2 disks. Please ensure that both disks are created - you may size the second appropriately: this will be your data disk and will not be destroyed (by default) if the original Humio instance is terminated.

To find out more about Humio, please see our [documentation pages](https://docs.humio.com).

If you have questions or need help, send us a mail on
[support@humio.com](mailto:support@humio.com) or join our Slack
community on [community.humio.com](http://community.humio.com).
