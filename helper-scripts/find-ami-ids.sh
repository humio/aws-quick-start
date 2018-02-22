#!/bin/bash

# Helper script to find AMI's on all regions for a given AMI name

#set -x
set -e

NAME="ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20180126"

function get_image {
    aws --region=$1 ec2 describe-images --filters Name=name,Values=$NAME | jq -r '.Images[].ImageId'
}

function get_and_print {
    IMG=`get_image $1`;
    echo "\"$1\": { \"id\": \"$IMG\" },"
}

get_and_print "us-east-1"
get_and_print "ap-south-1"
get_and_print "eu-west-3"
get_and_print "eu-west-2"
get_and_print "eu-west-1"
get_and_print "ap-northeast-2"
get_and_print "ap-northeast-1"
get_and_print "sa-east-1"
get_and_print "ca-central-1"
get_and_print "ap-southeast-1"
get_and_print "ap-southeast-2"
get_and_print "eu-central-1"
get_and_print "us-east-2"
get_and_print "us-west-1"
get_and_print "us-west-2"
