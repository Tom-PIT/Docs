# Environment

*Connected* is a controlled environment for development, testing, deploying, running and managing [Microservices](../Microservices/README.md).

The environment spans across different [Instances](Instance.md). The complete environment consists of:

- Development
- Quality 
- Staging
- Production
- [Connected Portal](ConnectedPortal.md)

Development and Quality [Instances](Instance.md) typically run locally on the user's laptop or workstation. Development is used by *Developers* whereas the Quality use *Quality Assurance* engineers.

*Staging* [Instance](Instance.md) runs in the Cloud, as well as *Production*.

Source code of the [Microservices](../Microservices/Model.md) is hosted in the [Repositories](../Deployment/Repositories.md) from where it is transferred between [Instances](Instance.md).

> It's not required for Development and Quality instances to have the same set of [Microservices](../Microservices/README.md) installed as they are later run in Staging and Production environment since the entire [Deployment](../Deployment/README.md) process is automated and configured from the [Connected Portal](ConnectedPortal.md).

Development and Quality instances have an [IDE](../IDE/README.md) installed but Staging and Production typically do not.

Development, Quality and Staging compile code in Debug mode while Production compiles in Release.