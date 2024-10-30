# Instance

An *Instance* represents a *Connected* process which is being run in a [Docker Container](https://www.docker.com/). Instance is fully managed through the [Connected Portal](ConnectedPortal.md) regardless of where they execute, in a [Public](PublicCloud.md) or a [Private](PrivateCloud.md) cloud.

An *Instance* consists of a:

- *Computing Power*, sometimes called **CPU**, which is represented as a number of *Processor Cores*
- *Memory Allocation*, which is represented as the amount of **RAM** that is statically dedicated to the *Instance*

## Subscriptions

Each *Instance* belongs to exactly one [Subscription](Subscription.md) which must be first created and activated. Each [Subscription](Subscription.md) can contain an unlimited number of *Instances*.

*Connected* offers three types of *Instances*:

- *Application*
- *Database*
- *SaaS*

## Application Instance

*Application Instance* represents an *Instance* which contains one or more [Microservices](../Microservices/README.md). [Microservices](../Microservices/README.md) are [Deployed](../Deployment/README.md) to the *Instance* through the [Connected Portal](ConnectedPortal.md). An *Application Instance* can contain unlimited [Microservices](../Microservices/README.md) although in large scale environments its probably better idea to split [Microservices](../Microservices/README.md) across several *Instances*. A [Subscription](Subscription.md) can contain unlimited *Application Instances*.

## Database Instance

*Database Instance* represents a container which has one of the following database servers pre-installed:

- Microsoft SQL Server
- PostgreSQL [^1]

*Database Instance* can contain unlimited databases, and they can be used by a different *Application* and *SaaS* *Instances*. A [Subscription](Subscription.md) can contain unlimited *Database Instances*.

> [!NOTE]
> [Microservices](../Microservices/README.md) do not depend on a specific type of database. They can run on any supported type of database type without any modifications.

## SaaS Instance

*SaaS Instances* are a special type of *Application Instances*. They are very similar in that they run [Microservices](../Microservices/README.md) but with the exception they come with a pre-built image where [Microservices](../Microservices/README.md) are already present in binary format instead of source code.

*SaaS Instances* are fixed images that cannot change. They don't allow additional [Microservices](../Microservices/README.md) to be deployed or existing [Microservices](../Microservices/README.md) to be modified. They are used "AS IS". Namely, *Connected* offers most *SaaS* services as a single tenant service model, which run on their own hardware resources instead of being shared across multiple subscriptions.

## Creating Instances

Before you can create a new *Instance* you must first have a valid *Connected* [Subscription](Subscription.md).

Once you have an access to the [Subscription](Subscription.md) you can start creating new *Instances*.

To create a new *Instance* follow the steps below:

1. go to the [Connected Portal](ConnectedPortal.md) by typing the following address into the Web Browser's address bar: https://connected.tompit.com/subscription
2. click on the **Services** card
3. an existing services are displayed and a **New Service** button
4. click on the **Add New** button and the screen displays all available services which you can add to your [Subscription](Subscription.md)

### Create a Database Instance

To create a new *Database Instance* follow this steps:

1. select **Microsoft SQL Server**
2. select one of the available **Data Centers** from the list. If you have a [Private](PrivateCloud.md) Cloud you'll probably prefer to use this option

> [!WARNING]
> You cannot change **Data Center** later so be careful to select a correct one.

7. enter a name of the *Instance*, for example **SQL**.
8. select **Resource Type** and its **Type**

> You can change **Resource Type** and **Type** anytime later.

### Create an Application Instance

To create a new *Application Instance* follow this steps:

1. select **Application**
2. select one of the available **Data Centers** from the list. If you have a [Private](PrivateCloud.md) Cloud you'll probably prefer to use this option

> [!WARNING]
> You cannot change **Data Center** later so be careful to select a correct one.  

3. enter a name of the *Instance*, for example **Default**.
4. select one of the **Service Resources** from the list.

> You can change **Service Resources** anytime later.

5. select one of the available **Stages**:

 - [Staging](Staging.md)
 - [Production](Production.md)
 
6. select the **Optimization Level**. If you intend to *Debug* the *Instance* select **Debug**, otherwise select **Release**. You should always select a **Release** for [Production](Production.md) *Instances* 
7. select a **Database Instance**. You can attach to the existing *Database Instance* or create a completely new inline.

## Complete the Create Process

To complete creating a new instance please follow this steps:

1. click on the **CREATE** button and the screen returns to the list of existing services. A message is displayed that a new service will be available shortly.
2. once the service has been successfully created it will be displayed in the list of services

The newly added [Instance] is **Stopped** by default. You must start it manually. To start an *Instance* follow this steps:

1. click on the **Service Card**
2. a Service interface opens with the toolbar with two buttons, **Start** and **Restart**. If the *Instance* is started, the **Stop** button is displayed instead of **Start**
3. the same procedure applies when **Stopping** an instance 

> [!WARNING]
> Running an *Instance* in the [Public](PublicCloud.md) incurs costs so make sure only authorized people have access to this resources.
---

[^1]: currently in Beta and not publicly available yet