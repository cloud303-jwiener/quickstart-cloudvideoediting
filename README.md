# quickstart-cloudvideoediting
## Cloud Video Editing on AWS

This Quick Start deploys a highly available architecture for cloud video editing on the Amazon Web Services (AWS) Cloud. The deployment uses Amazon Simple Storage Service (Amazon S3), Amazon Elastic Compute Cloud (Amazon EC2), Amazon Virtual Private Cloud (Amazon VPC), AWS Directory Service, and Remote Desktop Gateway instances.

Deploying on AWS yields a high-performing environment for transforming videos. Video editing involves large files and requires powerful graphics processing unit (GPU) workstations. Amazon Simple Storage Service (Amazon S3) provides durable, scalable object storage. 

With Teradici’s PC-over-IP (PCoIP) technology, video editors modify content on a remote workstation, avoiding large data transfers to a local machine. An Amazon Elastic Compute Cloud (EC2) G3 GPU instance is a robust, low-cost model for graphics-heavy workloads. Remote Desktop Gateway (RD Gateway) gives administrative access to the environment, and AWS Directory Service for Microsoft Active Directory enables AWS resources to use Active Directory.

The AWS CloudFormation templates included with the Quick Start automate the following:

- Deploying a cloud video editing environment into a new VPC
-	Deploying a cloud video editing environment into an existing VPC

You can also use the CloudFormation templates as a starting point for your own implementation.

![Quick Start architecture for a cloud video editing environment on AWS](https://d0.awsstatic.com/partner-network/QuickStart/datasheets/cloud-video-editing-architecture-on-aws.png)

For architectural details, best practices, step-by-step instructions, and customization options, see the 
[deployment guide](https://fwd.aws/4A4Ab).

To post feedback, submit feature ideas, or report bugs, use the **Issues** section of this GitHub repo.
If you'd like to submit code for this Quick Start, please review the [AWS Quick Start Contributor's Kit](https://aws-quickstart.github.io/). 
