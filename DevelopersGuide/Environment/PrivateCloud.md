# Private Cloud

In *Connected* [Staging](Staging.md) and [Production](Production.md) environments run in a Cloud. A Cloud represents a complex infrastructure of system software which orchestrates the computing power and software management.

Most *Connected* environments are powered by a [Public Clouds](PublicCloud.md) but there are no limitations for running the entire Stack in the *Private Cloud*.

*Private Cloud* is sometimes called On-Premises, which means the customer run the platform in the infrastructure of its choice. It can run on site or on a third party cloud infrastructure, for example [Azure](https://azure.microsoft.com/en-us/) or [AWS]( https://aws.amazon.com/).

To be able to run the [Digital Content](DigitalContent.md), *Connected* needs a Stack of technologies.

You cannot create a *Private Cloud* without Tom PIT support because it needs to be property configured and registered in the [Connected Portal](ConnectedPortal.md). A *Private Cloud* uses exactly the same software as [Public Clouds](PublicCloud.md) do, with the only exception that it is managed exclusively by you and is not visible to other customers.

## Prerequisites

Once you've agreed the Business details, Tom PIT Customer Service will be in touch with you and will take charge of the setup process. There are some prerequisites that you will need:

- A hardware resources (dedicated processor cores and RAM)
- Linux virtual machine
- Kubernetes 1.27+ (Tom PIT will configure Master which will manage the Cluster)
- An active internet connection

It's not required the internet connected to be constantly active but for managing [Instances](Instance.md) and [Deployment](../Deployment/README.md) this is a requirement.

Also, the communication between [Connected Portal](ConnectedPortal.md) and a *Private Cloud* will go through a Virtual Private Network Communication (VPN) so a tunneling between *Connected Portal* and your Cloud should be established. Since you will control the *Private Cloud* you can control the connection as well, you can keep the connection alive all the time or you can establish the connection as needed.