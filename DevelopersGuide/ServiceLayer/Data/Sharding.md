# Sharding

In most cases, the default storage architecture, such as relational database, is sufficient for efficient data access event if we store data over a long period of time. However, there are cases where there is simply too many records in one single physical entity which influences the performance. Sometimes we don't even have an idea in advance, how many records a specific [Entity](../Entities/README.md) will contain. Storing millions of records continuously degrades the performance to such an extend the system eventually becomes unresponsive. Databases provide indexing features which are great but they have limitations as well.

Storing records of the same [Entity](../Entities/README.md) in a distributed storage is called *Sharding*. *Sharding* consists of one ore more *Nodes* each providing a separate storage, typically a database. *Nodes* provides just a storage capacity, they don't handle the schemas or perform queries, they are simply a pointers to storages.

Then comes a *Shard* which provides a partially storage of [Entity's](../Entities/README.md) records. In fact, *Shard* is in *Connected* defined as a pointer of group of records to the specific *Node*.

*Shards* are handled by ```IShardingNodeProvider```, where each provider manages the single [Entity](../Entities/README.md). *Connected* supports *Sharding* out of the box but at the same time it provides very open infrastructure with a goal to leave the ultimate decisions to the providers which enables flexible and high performant solutions. 

*Sharding* is an optional feature meaning you can start with an [Entity](../Entities/README.md) without implementing it as a *Sharding* one. Once you get to the point where records are starting to growi, you can implement a provider for the specific [Entity](../Entities/README.md) and the system will continue to work without modifications.

## Implementation

Implementing a *Sharding* in a *Connected* is unbelievable easy. In fact, in most cases, you will end up with only three lines of implementation code, for example:

```csharp
if (Operation is null)
    return await Nodes.Query(null);
    
return await Sharding.ResolveNode<IProject>(Nodes, Operation, nameof(IWorkItem.Project));
```

Well, this really is sufficient to enable *Sharding* on the particular [Entity](../Entities/README.md). But let's go step by step through a simple example.

> The source code for this example is available in the [Connected.Academy.Sharding](https://connected.tompit.com/repositories?folder=Repositories%252FConnected%2520Academy&document=831&type=Repository) repository.

### Scenario

Suppose you have ```Projects``` where each ```Project``` contains many ```WorkItems```. You start with an ```IProject``` [Entity](../Entities/README.md) as the following code shows:

```csharp
namespace Connected.Academy.Sharding.Projects;

public interface IProject : IEntity<int>
{
	string Name { get; init; }
}
```

Then we would model an ```IWorkItem```:

```csharp
namespace Connected.Academy.Sharding.WorkItems;

public interface IWorkItem : IEntity<long>
{
	int Project { get; init; }
	string Text { get; init; }
}
```

You can see the ```IWorkItem``` has a reference to the ```IProject``` via ```Project``` property.

Imagine now you start using the [Microservices](../../Microservices/README.md) and after a few months you realize that ```IWorkItem``` storage is starting to grow to fast and in the two years time you could end up with a few millions of records.

You decide to introduce a *Sharding* for an ```IWorkItem``` entity. You will typically create a new [Microservice](../../README.md) because you don't want to mix optional features with default ones. If you'd do a *Sharding* on [Core](../../Environment/Core.md) [Entities](../Entities/README.md) you'd do it via external [Microservice](../../Microservices/README.md) to avoid [Branching](../../Deployment/Repositories.md#branches).

The first this you are interested in is the ```Insert``` event in the ```IProjectService```. This is where you will create a new *Shard*. The following code shows how to achieve this:

```csharp
using TomPIT.Notifications;
using TomPIT.Data.Sharding;
using TomPIT.Data.Sharding.Nodes;
using Connected.Academy.Sharding.Projects;

namespace Connected.Academy.Sharding;

[Middleware<IProjectService>(nameof(ServiceEvents.Inserted))]
internal sealed class InsertProjectListener : EventListener<PrimaryKeyEventDto<int>>
{
	public InsertProjectListener(IShardingService sharding, IShardingNodeService nodes)
	{
		Sharding = sharding;
		Nodes = nodes;
	}

	private IShardingService Sharding { get; }
	private IShardingNodeService Nodes { get; }

	protected override async Task OnInvoke()
	{
		var shards = await Sharding.Query(new QueryShardsDto
		{
			Entity = typeof(IProject).EntityKey()
		});

		var node = shards.ChooseNodeCandidate(await Nodes.Query(null));

		if (node is null)
			return;

		await Sharding.Insert(new InsertShardDto
		{
			Entity = typeof(IProject).EntityKey(),
			EntityId = Dto.Id.ToString(),
			Node = node.Id
		});
	}
}
```

Let's explain the preceding code step by step. First, we implemented the ```EventListener``` middleware for a ```PrimaryKeyEventDto<int>``` because we the ```int``` is the return value of the ```IProjectService.Insert``` [Service Operation](../Services/Operations.md) (we can always look into the model of course for the signatures). Next, we decorated the [Middleware](../Middleware.md) with an attribute instructing the [Event Service](../Notifications/Events.md) to call out component when ```Insert``` was performed in the ```IProjectService```. 

Once our [Middleware](../Middleware.md) takes place we have a simple task to do, to decide in which *Node* the newly inserted ```IProject's``` ```IWorkItem```s will be stored. We usually need to services for this:

- ```IShardingNodesService```
- ```IShardingService```

The first of the mentioned services provides us access to the registered *Nodes*. The latter provides us a storage for a *Sharding* definition. Our algorithm is simple. First, we perform a query for existing shards for the ```IProject``` entity. Once we have shards we simply call the extension method to do the work for us and to decide which node, if any, is best fit for the newly inserted ```IProject```. If no active *Nodes* exist, this method will return ```null``` which means the records will be stored in the default storage. If a node has been found, we simply create a new *Shard* for the ```IProject```.

There are a few things to consider. First, *Shards* are always created for the master record, which is ```IProject``` in our case. Second, by using the extension method ```ChooseNodeCandidate``` we will achieve even distribution of data over time. If we later add a new *Node*, this algorithm will return the new node until the same amount of *Shards* are added to the *Node*. As you can see, there are no ```IWorkItems``` involved at this stage. 

Now that we have a *Sharding* creation covered let's see the implementation of the ```IShardingNodeProvider```.

```csharp
using TomPIT.Data.Sharding;
using TomPIT.Entities.Storage;
using Connected.Academy.Sharding.WorkItems;
using TomPIT.Data.Sharding.Nodes;
using Connected.Academy.Sharding.Projects;

namespace Connected.Academy.Sharding;

internal sealed class WorkItemsShardingProvider : ShardingNodeProvider<IWorkItem>
{
	public WorkItemsShardingProvider(IShardingService sharding, IShardingNodeService nodes)
	{
		Sharding = sharding;
		Nodes = nodes;
	}

	private IShardingService Sharding { get; }
	private IShardingNodeService Nodes { get; }

	protected override async Task<ImmutableList<IShardingNode>> OnInvoke()
	{
		/*
       * Return all nodes if operation has not been passed because this call
       * performs Schema Middleware when synchronizing storage schemas.
       */
		if (Operation is null)
			return await Nodes.Query(null);
		/*
       * Operation should contain a Project property.
       */
		return await Sharding.ResolveNode<IProject>(Nodes, Operation, nameof(IWorkItem.Project));
	}
}
```

Let's explain how this [Middleware](../Middleware.md) works. First, there are three scenarios where this [Middleware](../Middleware.md) will be involved:

- Synchronizing `IWorkItem` schema
- Reading work items
- Writing work items

### Synchronizing

On [Startup](../../Microservices/Startup.md), the [Core](../../Environment/Core.md) performs synchronization of storage schema for each [Entity](../Entities/README.md) that is implemented in the [Microservice](../../Microservices/README.md) which has been recompiled.

Once the synchronization process starts, it is executed in two stages. In the first stage, the [Core](../../Environment/Core.md) performs synchronization in the default storage. Then it searches for each [Entity](../Entities/README.md) ```IShardingNodeProvider``` [Middleware](../Middleware.md). If one exists, it performs ```Invoke``` but it doesn't pass the ```IStorageOperation``` which is ```null``` in this context. When you implement the [Middleware](../Middleware.md) you should always look if the ```Operation``` property is ```null```. If so, return all available *Nodes* because the [Core](../../Environment/Core.md) needs to synchronize schemas on all *Nodes*.

### Reading

Reading, or querying data, always performs lookup first in the [Middleware](../Middleware.md) and passes the ```IStorageOperation``` that will be executed on all returned *Nodes*. In most cases, you will return only one *Node* since the queries usually span across the one group set. But there are cases where the query will have to be performed on more *Nodes*. In this case, you will have to return all *Nodes* where the data exists. You don't have to really worry about performing storage calls and merging data, this is something which ```IStorageProvider``` handles for you.

### Writing

Writing data means executing transactions and you should return only one *Node* if this is the case because every record should be stored only once. *Sharding* is not about replicating data, it's about distributing it.

### Understand ```IStorageOperation```

The question is how do you know which *Node* select or from where this information comes. *Sharding* does not know anything about [Dto](../Services/Dto.md) objects since the Sharding lies way below the [Service Layer](../README.md) where the [Dto](../Services/Dto.md) is already gone and we are dealing exclusively with the [Entities](../Entities/README.md). This is why *Sharding* is based on an [Entity](../Entities/README.md) rather than [Dto](../Services/Dto.md). The only information in this stage is the ```IStorageOperation``` which contains all information about the either query or transaction that is about to be executed. Luckily, this object provides us with enough information in most cases. By calling ```ResolveNode``` extension method we simply delegate the work to this method to find out which node to select.

There will be cases where this scenario might not work for you but the important fact is the [Middleware](../Middleware.md) has a total control of how, when and where the data will be stored. 