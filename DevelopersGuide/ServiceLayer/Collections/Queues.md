# Queues

Queues represent internal services for background, parallel and asynchronous processing of tasks which deal with data analyzing and processing.

*Connected* recommends any data which is not directly entered by clients should be processed in background. The best option in most scenarios are Queues.

Queues consists of an ```IQueueMessages```. ```IQueueMessages``` are [Resources](../Artifacts/Resources.md) in that way they are utilized by ```IQueueClients```. ```IQueueMessages``` have a number of properties which defines their behavior. ```IQueueMessages``` are inserted in the ```IQueueService``` from where they are dequeued by ```IQueueHost```. ```IQueueHost``` then requests an ```IQueueClient``` from [Dependency Injection](../DependencyInjection/README.md) container. If the message processing succeeds, the message gets deleted. If it fails, a number of retries are performed until the message processing succeeds or ultimately fails because of its deadline passed of number of retries exceeds its maximum.

## Creating Queue Messages

```IQueueMessage``` is never created directly but rather by calling ```Insert``` [Service Operation](../Services/Operations.md) on the ```IQueueService```. ```Insert``` accepts two [Dto](../Services/Dto.md) arguments where the first [Dto](../Services/Dto.md) is the actual [Dto](../Services/Dto.md) argument containing the data needed to process a message. The second [Dto](../Services/Dto.md) argument are options how a message should be created.

> Source code for this example is available in the [Connected.Academy.Queues](https://connected.tompit.com/repositories?folder=Repositories%252FConnected%2520Academy&document=825&type=Repository) repository.

There is another important argument that has to be passed when calling ```Insert``` - the type of the client which will process the message. For example:

```csharp
using TomPIT.Collections.Queues;

namespace Connected.Academy.Queues;

internal sealed class Insert : ServiceAction<IDto>
{
	public Insert(IQueueService queue)
	{
		Queue = queue;
	}

	private IQueueService Queue { get; }

	protected override async Task OnCommitted()
	{
		var dto = new CalculatorDto
		{
			Value = 10
		};

		await Queue.Insert<CalculatorClient, CalculatorDto>(dto, new InsertOptionsDto
		{
			Queue = "Calculator"
		});
	}
}
```
The preceding code shows how to create a new queue message. First, we need an ```IQueueService``` from the [Dependency Injection](../DependencyInjection/README.md) container. Then, we are waiting for the [Service Operation](../Services/Operations.md) to enter a [Commit](../Services/Operations.md#commit) stage. Finally, we simply perform a call on ```IQueueService.Insert``` [Service Operation](../Services/Operations.md). We pass ```CalculatorClient``` as a client to process a message and ```CalculatorDto``` as a [Dto](../Services/Dto.md) argument. In options we only set the name of the ```Queue``` to **Calculator**.

Let's see how a ```CalculatorClient``` would be implemented:

```csharp
using TomPIT.Collections.Queues;

namespace Connected.Academy.Queues;

internal sealed class CalculatorClient : QueueClient<CalculatorDto>
{
	protected override async Task OnInvoke()
	{
		var value = Dto.Value * 2;

		await Task.CompletedTask;
	}
}
```

```CalculatorClient``` simply inherits from ```QueueClient```. It overrides ```OnInvoke``` method and perform the needed actions.

### InsertOptionsDto

There are several options that can be set when creating a queue message. Please look at the source code documentation of the [InsertOptionsDto](https://connected.tompit.com/repositories?folder=Repositories%252FTom%2520PIT&document=102&type=Repository) for detailed information how to fine tune queues.

## Processing Messages

Once the message is created, it waits in the queue until one of the ```QueueHosts``` dequeues it. One ```QueueHost``` process one queue, but one queue can contain messages of different clients. Let's take a look at the example of the ```QueueHost```:

```csharp
using System.Collections.Concurrent;
using TomPIT.Collections.Queues;

namespace Connected.Academy.Queues;

internal sealed class CalculatorHost : QueueHost
{
	public CalculatorHost() : base("Calculator", 2)
	{

	}

	protected override async Task<bool> Accept(ConcurrentQueue<IQueueMessage> queue, IQueueMessage message)
	{
		await Task.CompletedTask;

		return queue.FirstOrDefault(f => f.Client == typeof(CalculatorClient)) == null;
	}
}
```
```CalculatorHost``` inherits from ```QueueHost``` which accepts two constructor arguments, the name of the queue to be processed and a maximum number of parallel threads for processing. You don't really have to do anything else for the host to be running properly.

There is one interesting method which can be overridden though, ```Accept```. The host calls this method whenever intends to put a message in the process pipeline. It asks if it is allowed to do is and this is the perfect point to control which messages to process. In case of rejecting a message it is returned back to the queue for later processing. In the preceding code we allow only one type of the ```CalculatorClient``` to be run at the same time.