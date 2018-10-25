#!/bin/bash

aws --region=eu-west-1 s3 cp aws/single-server-cloud-formation.json s3://humio-aws-quick-start/ --acl public-read
