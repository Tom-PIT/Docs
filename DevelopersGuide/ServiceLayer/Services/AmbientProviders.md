# Ambient Providers
[Dto](Dto.md) object typically contains sufficient data for the [Service Operation](../Services/Operations.md) to be able to perform its actions. Sometimes though some data is either not provided by a [Dto](Dto.md) because the [Service](../Services/README.md) does not want to expose sensitive data to be passed from the client or a [Service Operation](../Services/Operations.md) needs additional data because of the implementation specifics.
By following a [Separation of Concerns](https://en.wikipedia.org/wiki/Separation_of_concerns) principle the [Service Operation](../Services/Operations.md) should not perform any specific data retrieval actions but expects the data to be already available and validated once the [Service Operation](../Services/Operations.md) is instantiated.

In scenarios where a [Dto](Dto.md) does not provide the entire property set we use ```IAmbientProvider``` [Middleware](Middlewares.md).

```IAmbientProvider``` can contain any schema and is always specific to exactly one [Dto](Dto.md). ```IAmbientProvider``` is automatically registered on [Startup](../../Environment/Startup.md) and is thus available from [Dependency Injection](../DependencyInjection/README.md) container.

> Microservice for this example is available in the [Ambient Providers](https://connected.tompit.com/repositories?folder=Repositories%252FConnected%2520Academy&document=818&type=Repository) repository.

Let's see an example. We have a [Dto](Dto.md) named ```InsertCommentDto``` with the following code:
```csharp
namespace Connected.Academy;

public class InsertCommentDto : Dto
{
	[Required, MaxLength(256)]
	public string Text { get; set; } = default!;
}
```
The client just needs to pass a ```Text``` in the ```ICommentService``` operation named ```Insert```. The code below shows a model of the ```ICommentService```.
```csharp
namespace Connected.Academy.AmbientProviders;

[Service, ServiceUrl("services/connected/ambient-providers")]
public interface ICommentService
{
	[ServiceOperation(ServiceOperationVerbs.Post | ServiceOperationVerbs.Put)]
	Task Insert(InsertCommentDto dto);
}
```
Now let's look at a model of the ```IComment``` entity in the following code:
```csharp
namespace Connected.Academy.AmbientProviders;

public interface IComment : IEntity<int>
{
	string Text { get; init; }
	DateTimeOffset Created { get; init; }
	string Identity { get; init; }
}
```
As you can see the ```Entity``` contains two additional properties, named ```Created``` and ```Identity```. We don't want the client to pass those two properties directly since it could do an impersonation and could send a ```Created``` value of a year 2050, for example.

By performing an ```Update``` on the [Storage](../Data/Storage.md), the [Storage Provider](../Data/StorageProviders.md) will expect those two properties to be passed in the call since the entities' properties are not [nullable](../Entities/Nullability.md).

Now let's see how this challenge is solved.

We'll model an ```IAmbientProvider``` for the missing properties, named ```IInsertCommentAmbient``` as follows:
```csharp
namespace Connected.Academy.AmbientProviders;

public interface IInsertCommentAmbient : IAmbientProvider<InsertCommentDto>
{
	string Identity { get; set; }
	DateTimeOffset Created { get; set; }
}
```
The [Middleware](Middlewares.md) inherits from ```IAmbientProvider``` which depends on a specific [Dto](Dto.md). This is very useful because it gives us a reference to the actual [Dto](Dto.md) passed by the client when providing the values.

Our provider introduces the missing properties and will be later used in the [Service Operation](Operations.md). Let's implement the provider first with the following code:
```csharp
using TomPIT.Authentication;

namespace Connected.Academy.AmbientProviders;

internal sealed class InsertCommentAmbient : AmbientProvider<InsertCommentDto>
{
	public InsertCommentAmbient(IAuthenticationService authentication)
	{
		Authentication = authentication;
	}

	private IAuthenticationService Authentication { get; }

	public string Identity { get; set; } = default!;

	public DateTimeOffset Created { get; set; }

	protected override async Task OnInvoke()
	{
		if (Authentication.Identity is null)
			throw new NullReferenceException(TomPIT.Strings.ValInvalidUser);

		Identity = Authentication.Identity.Token;
		Created = DateTimeOffset.UtcNow;

		await Task.CompletedTask;
	}
}
```
First, we request ```IAuthenticationService``` from the [Dependency Injection](../DependencyInjection/README.md) container. The ```IAuthenticationService``` will be needed to retrieve the current identity since we would like to perform an insert with the currently authenticated client.

If the request is not authenticated we are throwing an ```Exception``` because identity is non [nullable](../Entities/Nullability.md) property on the entity. If the request is authenticated we simply set ```Identity``` property from the authenticated identity token.

Dealing with a ```Create``` property is much more simple. We just take the current ```UTC``` time because we want to perform insert with the timestamp as close to the insert event as possible.

Now let's see how ```IAmbientProvider``` is used in a [Service Operation](../Services/Operations.md).
```csharp
using TomPIT.Entities.Storage;

namespace Connected.Academy.AmbientProviders;

internal sealed class Insert : ServiceAction<InsertCommentDto>
{
	public Insert(IStorageProvider storage, IInsertCommentAmbient ambient)
	{
		Storage = storage;
		Ambient = ambient;
	}

	private IStorageProvider Storage { get; }
	private IInsertCommentAmbient Ambient { get; }

	protected override async Task OnInvoke()
	{
		await Storage.Open<Comment>().Update(Dto.AsEntity<Comment>(State.New, Ambient));
	}
}
```
As you can see, in addition to the usual [IStorageProvider](../Data/StorageProviders.md) we also requested ```IInsertCommentAmbient``` from the [Dependency Injection](../DependencyInjection/README.md) container and all we had to do was to pass an additional argument into the ```Update``` call of the [Storage](../Data/Storage.md). *Connected* will do the rest, merging all values together and preparing the ```Entity``` for the insert.

> Note that there is not need to register ```IAmbientProvider``` manually. It gets registered automatically on [Startup](../../Environment/Startup.md).

## Overwriting properties

You have probably noticed that we modeled ambient properties as writable. It was intentional because we want the [Middleware](Middlewares.md) to be open, similar to the [Dto](Dto.md) concept. For example, we could later write another [Microservice](../../Microservices/README.md) which would overwrite the identity and try to retrieve it from some remote service without the need to change the existing code.

Let's imagine we have a customer requirement that comments should not be created on *Sunday*. If client tries to insert a comment on *Sunday* we have to move the actual creation date to *Monday*.
The following code shows how the challenge is solved:
```csharp
namespace Connected.Academy.AmbientProviders;

internal sealed class CreatedCalibrator : Calibrator<InsertCommentDto>
{
	public CreatedCalibrator(IInsertCommentAmbient ambient)
	{
		Ambient = ambient;
	}

	private IInsertCommentAmbient Ambient { get; }

	protected override async Task OnInvoke()
	{
		if (Ambient.Created.DayOfWeek === DayOfWeek.Sunday)
			Ambient.Created = Ambient.Created.AddDays(1);
	}
}
```
Note that this code would typically reside in another [Microservice](../../Microservices/README.md). For more information on the preceding example please read how the [Calibrators](Calibrators.md) work.

In cases where we don't want to enable other components to influence the ambient, the model is typically defined in the implementation [Microservice](../../Microservices/README.md) as an internal component instead of the model [Microservice](../../Microservices/README.md) where it is publicly visible by default. 

## Summary

Ambient providers are a powerful technique for achieving a [Separation of Concerns](https://en.wikipedia.org/wiki/Separation_of_concerns) principle and to provide an otherwise missing properties in [Dto](Dto.md).