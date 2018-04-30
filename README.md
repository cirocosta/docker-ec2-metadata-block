# Example of EC2 Metadata service blocking for Docker container

This repository contains an example configuration of how to block requests from Docker containers to the EC2 metadata service without disrupting role-based access to IAM that a host's process might need.

It requires:

1. [Terraform](https://www.terraform.io/docs/providers/aws/r/instance.html) to be installed - for provisioning the AWS resources;
2. A AWS account with a profile set locally (so you can provide the `terraform` execution with a `profile` variable to configure the AWS provider).

After the Terraform configuration is applied, the following is achieved:

<img src="https://ops.tips/blog/-/images/ec2-metadata-block-overview.svg" alt="Overview of what's set up in this repository" width="100%">

Being `awsmon` the process making use of role-based IAM authentication, we're able to access EC2 metadata from processes spawned directly in the host but still restrict access from docker containers.


