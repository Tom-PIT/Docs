# Saga Transactions

[Microservices](../../Microservices/README.md) typically provide [Services](../Services/README.md) which exposes [Entity](../Entities/README.md) manipulation. [Entities](../Entities/README.md) are typically stored in a physical storage. When performing ```insert```, ```update``` or ```delete``` actions, the [Transactions](Transactions.md) are involved. In a [Service Operation](../Services/Operations.md) call there can be many different [Microservices](../../Microservices/README.md) involved but each [Microservice](../../Microservices/README.md) can have its very own physical storage which means that when performing batch transactions on multiple [Microservices](../../Microservices/README.md), we need a reliable infrastructure to synchronize transactions. 

The infrastructure which deals with with the challenges stated above is called **Saga** transactions. There are two principles involved:

- Choreography
- Orchestration

*Connected* implements both principles because in modern business environment there is absolutely a need for both of them.

## Choreography

Choreography is based on [Events](../Notifications/Events.md) which are triggered as part of the [Service Operations](../Services/Operations.md). When an [Event](../Notifications/Events.md) is triggered, an in-process ```IEventListener``` components are invoked and an out-of-process broadcast is performed to the remote endpoints.

## Orchestration

This principle is based on a local orchestration [Middleware](../Middleware.md) which manages a lifetime of all [Transactions](Transactions.md). The service which manages the orchestration is [```ITransactionContext```](Transactions.md#itransactioncontext).

## Two Phase Commits

Two Phase Commits are typically implemented in a distributed systems, commonly via REST services. Since those services are stateless, there is no way to keep transactions alive but to call each transaction twice, first with the actual intention, for example by calling ```Insert```, and the second time with the confirmation. Those systems have many disadvantages and *Connected* does not provide a direct support for them. You can always rely on a ```OnCommitted``` and ```OnRolledBack``` methods in the [Service Operations](../Services/Operations.md) to handle those scenarios in a way the best suit your needs.

But *Connected* has a full support for  **Saga** transactions. In fact, **Saga** transactions are fundamental part of the *Connected's* transaction model and are handled implicitly and invisible to the developer.