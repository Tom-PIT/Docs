# Deployment

*Connected* uses a centralized source code management system for versioning and deployment of [Microservices](../Microservices/README.md). The only way to transfer changes between environments is by using the [Repositories](Repositories.md).

*Connected* provides fully automatic *Deployment* infrastructure without the need to manually install or upgrade [Microservices](../Microservices/README.md).

## Development and Quality

[Development](../Environment/Development.md) and [Quality](../Environment/Quality.md) [Instances](../Environment/Instance.md) do not use the [Images](Images.md) since they not contain an actual [Image](Images.md) which is run on an either [Staging](../Environment/Staging.md) or [Production](../Environment/Production.md) [Instance](../Environment/Instance.md).

Those two [Instances](../Environment/Instance.md) use primarily an [IDE](../IDE/README.md) to retrieve the changes they need. Namely, a *Developer* or a *Quality Assurance Engineer* typically works on a specific feature which is implemented and the entire production image is in most cases not necessary. Once the [Quality](../Environment/Quality.md) stage is completed the *Deployment* infrastructure takes place.

## Staging and Production

[Staging](../Environment/Staging.md) and [Procution](../Environment/Production.md) [Instances](../Environment/Instance.md) are fully managed by a *Connected Deployment Infrastructure*. Every [Instance](../Environment/Instance.md) has an [Image](Images.md) which describes which set of [Microservices](../Microservices/README.md) is installed. If we want to upgrade an [Instance](../Environment/Instance.md) we do it through the *Connected Portal*. To perform an *Upgrade* or a *Fresh Install* follow this steps:

- Go to the *Connected Portal* and click **Services**
- Click on the Service you would like to upgrade
- Click on the **Deployment** Tab
- Click on the Image you would like to deploy
- Click on the **Deploy** button

By clicking on the **Deploy** button the deployment process starts. *Connected* first reads the [Image](Images.md) to find out which [Microservices](../Microservices/README.md) are part of the target [Instance](../Environment/Instance.md). Then it performs a call to the [Instance](..//Environment/Instance.md) for every [Microservice](../Microservices/README.md). The call hits the [Shell](../Environment/Shell.md) which performs the following:

- performs a check which [Commit](Repositories.md#commits) is installed for the specified [MicroService](../Microservices/README.md)
- performs a call to the [Repositories](Repositories.md) and requests changes from the installed [Commit](Repositories.md#commits) on
- synchronizes the received source files with the local ones
- performs a restart
- a recompile occurs for every changed [Microservice](../Microservices/README.md)
- notifies *Connected Portal* that an upgrade completed either successfully of it's failed

> In some Cloud environments *Connected* performs an upgrade by creating a shadow copy of the environment, performs an upgrade, starts the upgraded [Instance](../Environment/README.md) and then performs a how swap with existing [Instance](../Environment/Instance.md). This way there is a virtually not downtime when upgrading an [Instance](../Environment/Instance.md).