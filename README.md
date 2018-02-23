Note, this repository is **Work In Progress!**

# Humio - AWS Quick Start

This guide will let you get started running with Humio on AWS.  It
uses AWS Cloud Formation templates and will create a single instance
of Humio with a connected data volume.

Just hit the "Launch Stack" button and follow the Create Stack Wizard.

[![Install Humio on AWS](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png "Install Humio on AWS")](https://console.aws.amazon.com/cloudformation/home?#/stacks/new?stackName=Humio&templateURL=https://s3-eu-west-1.amazonaws.com/humio-aws-quick-start/single-server-cloud-formation.json)

Launch Stack for VPC: stay tuned...

## Access Control

Humio will listen for HTTP traffic on port 8080, but the template have
an option to restrict access based on IP range. For a production setup
we advise you to put a HTTPS proxy in front of Humio or place it
inside your VPC.

## Sizing

Choosing the right instance size depends on your ingest volume and
usage patterns. As a general guideline the following table is a
starting point for sizing your Humio instance.

- Up to 5 GB/day: m4.medium
- Up to 15 GB/day: m4.large
- Up to 35 GB/day: m4.xlarge
- Up to 75 GB/day: m4.2xlarge
- Up to 150 GB/day: m4.4xlarge

For the general documentation of Humio, [click
here](https://cloud.humio.com/docs/)

If you have questions or need help, send us a mail on
[support@humio.com](mailto:support@humio.com) or join our Slack
community on [community.humio.com](http://community.humio.com).
