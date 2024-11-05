# Repositories

*Source Code Management* is an essential process of the software development. Source code can be be changed by different developers, event different development teams, each team or developer creating its own version of the same feature. The biggest pitfall lies in deployment process where the changes made must be integrated in a controlled and consistent manner. 

*Connected* provides its very own *Source Code Management* system, names **Repositories**. It a central, cloud based versioning system, integrated directly into [Development Environment](../IDE/README.md).

It provides all features you'd expect from a modern versioning system. 

Every [Subscription](../Environment/Subscription.md) has its own *Repositories* system where a [Subscription](../Environment/Subscription.md) specific source code of the [Microservices](../Microservices/README.md) can be hosted.

The only way to transfer code changes between [Instances](../Environment/Instance.md) is by using *Repositories*.

## Repository

A *Repository* represents a [Microservice](../Microservices/README.md). One [Microservice](../Microservices/README.md) equals to the one *Repository*. This means each [Microservice](../Microservices/README.md) can be hosted in exactly one [Subscription](../Environment/Subscription.md). If you need to perform changes to the [Microservice](../Microservices/README.md) which is hosted in a different [Subscription](../Environment/Subscription.md) you can create a new *Branch* and manage your changes independently.

A *Repository* can be **Public** or **Private**. By default and by following Tom PIT [Open License](https://www.tompit.com/legal) your work should be open sourced unless you own a commercial license which means a *Repository* should be **Public**.

### Create a Repository

You've created a new [Microservice](../Microservices/README.md), wrote some code and now you want to [Deploy](README.md) it to the [Production](../Environment/Production.md) [Instance](../Environment/Instance.md).

In the bottom right corner of the [IDE](../IDE/README.md) is the *Repositories* status bar with the following commands:

- Credentials
- Push
- Commits
- Pull
- Merge Request
- Branch

The following image shows the status bar:
![Repositories Status Bar](/Assets/RepositoriesStatusBar.png)

#### Credentials

Before you can use the *Repositories* you must connect your local credentials with the [Connected Portal](../Environment/ConnectedPortal.md). This is how your status bar would look like if you are not authenticated in the [Connected Portal](../Environment/ConnectedPortal.md):

![Repositories Status Bar Anonymous](/Assets/RepositoriesStatusBarAnonymous.png)

If you don't have a valid *Connected* account it's time to get one. To create an account, follow the steps in the [Connected Portal](../Environment/ConnectedPortal.md).

Once you have a valid account, click on an **Not Authenticated** button. A *Designer* opens up asking for a *Connected* credentials:
![Linkinkg Connected Account](/Assets/LinkConnectedAccount.png)

Enter *Connected* credentials and clock on a **Connect** button. If you've entered a valid credentials you will see your name displayed in the status bar.

You can now proceed with the creating a *Repository*. Click on a **Bind** button and a **Create Repository** designer will show up

![Create Repository](/Assets/CreateRepository.png)

In the **Subscription** select box you you will see all Subscriptions you have access to. Choose the `Subscription` carefully because you cannot move the *Repository* between subscriptions and each Microservice can be hosted in only one *Repository*.

By default, a **Make repository visible to everyone**  check box is checked meaning that your *Repository* will be public. All your *Repositories* should be public unless you own a *Connected* commercial license.
## Commits
//TBD
## Branches
//TBD