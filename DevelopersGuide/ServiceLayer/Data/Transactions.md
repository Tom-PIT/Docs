# Transactions

Transactions are a complex area since they are responsible for [Data Consistency](../Entities/Consistency.md). A [Service Operation](../Services/Operations.md) can perform many calls to other [Service Operations](../Services/Operations.md), which in turn perform a group of calls in itself on so on. It could end up with a few hundred calls just behind a simple [Service Operation](../Services/Operations.md) call. To make things even more complicated, in each [Pipeline](../Services/Operations.md#invocation-pipeline) there can be dozens of [Middleware](../Middleware.md) components involved, each of which with its own transaction set. You can imagine how hard would be to manually manage when and which transactions must be committed or rolled back.

On the other hand, transactions typically hold and exclusive locks in the storage which additionally complicate things. The goal is to lower the impact of each transaction as much as possible.

But, there are more challenges, as you'd imagine. Some [Service Operations](../Services/Operations.md) must share the same transaction scope to be able to have access to the same data, otherwise we'd quickly cause a deadlock. But, if they share the same transaction scope, they must participate in the same commit or rollback pipeline, which must be somehow managed. The same is true for out of scope transactions, they must not have access to the same data until it gets committed or rolled back.

Things get even worse when we include the [Caching](../Caching/README.md) which has the very same problem as storage but in the application level.

Dealing with transactions and synchronization is a really hard thing to do. Luckily, *Connected* solves all challenges states above to the scale that you'll never have a need to event think about any of the mentioned challenges. They are solved "under the hood", more precisely in [Core](../../Environment/Core.md) which does the job totally invisible from the developer.

## ITransactionContext

In the heart of the transaction orchestration there are two components:

- [IContext](../IContext.md)
- ITransactionContext

[Context](../IContext.md) is owner of everything. All components, apart from [Singleton Services](../Services/README.md#service-scope), are created from the this component. [Context](../IContext.md) is very expensive component so its lifetime should be carefully managed and it should be disposed as soon as possible.

One of the services that lives in the [Context](../IContext.md) is ```ITransactionContext```. This service is responsible for:

- managing the state of the [IContext](../IContext.md)
- orchestrating the [Service Operations](../Services/Operations.md) and performing commits and/or rollbacks when needed and in the correct order

The ```ITransactionContext``` takes place when a ```Commit``` or ```Rollback``` extension method is called on the ```IContext```. You will very rarely have to instantiate an ```IContext``` directly. When implementing [Service Operations](../Services/Operations.md) there is already one created and managed outside of your scope.

Also, you will never have to access the ```ITransactionContext``` since it doesn't provide any features you'd be interested in.

## IConnectionProvider 

When an ```ITransactionContext``` changes its state to either ```Committing``` or ```RollingBack```, another [Middleware](../Middleware.md) reacts, the ```IConnectionProvider```. This provider is responsible to provide all [Storage](Storage.md) connection for the scope and to manage their lifetime. ```ITransactionContext``` performs commits or rollbacks on [Service Operations](../Services/Operations.md), but ```IConnectionProvider``` performs the very same actions on [Storage](Storage.md) connections. ```IConnectionProvider``` performs its actions first so when the ```Commit``` or ```Rollback``` is called on the [Service Operation](../Services/Operations.md), the connections are already disposed.

## ICachingService

[Caching](../Caching/README.md) is another service which critically depends on ```ITransactionContext```. namely, all changes to the [Cache](../Caching/README.md) is performed in the scope until the ```Commit``` stage occurs. The changes are then merged with the shared scope. In case of ```Rollback``` there are no actions performed because the cache gets disposed anyway.

## Distributed Transactions

*Connected* does not provide a mechanism for managing distributed transactions. A call to the remote REST service cannot be managed by a *Connected* but it still offers a way to perform two phase commits. Those commits are part of the [Saga](Saga.md) transactions.
