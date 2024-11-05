# Service Operations

[Services](README.md) consists of one or more methods which are called operations. Operations are not typical methods found in ```classes```, they behave very differently. A typical Operation call has a complex, but well designed pipeline which executes in stages.

> It is not necessary to use the *Connected* service pipeline but it is highly recommended since it encapsulates all the complexity needed to properly execute a single operation.

> Source code for this document is available on [Connected.Academy.ServiceOperations](https://connected.tompit.com/repositories?folder=Repositories%252FConnected%2520Academy&document=819&type=Repository) repository.

## Model
Service operation in its model is just a method signature. An operation typically returns a ```Task``` which later enables ```async``` implementation if needed. In fact, virtually entire [Core](../../Environment/Core.md) Services are asynchronous. The following code shows an operation model:

```csharp
[Service, ServiceUrl("services/common-types/materials")]
public interface IMaterialService
{
    Task Update(UpdateMaterialDto dto);
}
```
In the preceding code, the ```Update``` method acts as a Service Operation. 

Operations, similar to Services, can be accessible to external clients. By default, they are regarded as non accessible. You don't need to decorate an Operation with a ```ServiceUrlAttribute``` attribute, but use ```ServiceOperationAttribute``` instead. We'll take a look at this attribute shortly, but let's first explain how the routing works. By default, the ```Url``` of the Operation is its name. You can always override default Operation's ```Url``` by specifying the ```ServiceUrl``` property on the Operation. This is very useful for overloaded Operations. For example:
```csharp
[Service, ServiceUrl("services/common-types/materials")]
public interface IMaterialService
{
	[ServiceOperation(ServiceOperationVerbs.Get)]
	Task<ImmutableList<IMaterial>> Query();

	[ServiceOperation(ServiceOperationVerbs.Get)]
	Task<ImmutableList<IMaterial>> Query(PrimaryKeyListDto<int> dto);
}
```
In the preceding code we have two perfectly legal C# operations with the same name but different set of parameters, which won't work when called by REST clients because *Connected* does not try to resolve requests by parameter types. Even if it would support it, this kind of behavior would be very unusual for web clients. Instead, we can simply write:
```csharp
[Service, ServiceUrl("services/common-types/materials")]
public interface IMaterialService
{
	[ServiceOperation(ServiceOperationVerbs.Get)]
	Task<ImmutableList<IMaterial>> Query();

	[ServiceOperation(ServiceOperationVerbs.Get)]
    [ServiceUrl("lookup")]
	Task<ImmutableList<IMaterial>> Query(PrimaryKeyListDto<int> dto);
}
``` 
The preceding code solves the challenge with overloaded methods by decorating them with ```ServiceUrl``` attributes. Now, the second method is accessible via ```lookup``` address.

 As mentioned previously, for the Operation to become accessible to external clients, it must be decorated with ```ServiceOperationAttribute``` which accepts ```ServiceOperationVerbs``` flags ```enum``` which defines what ```Http``` verbs are allowed on the Operation. From the example above:

```csharp
[Service, ServiceUrl("services/common-types/materials")]
public interface IMaterialService
{
    [ServiceOperation(ServiceOperationVerbs.Post)]
    Task Update(UpdateMaterialDto dto);
}
```

The ```Update``` method from the preceding code is a perfect example of a Service Operation model which is exposed as an external service.

The Operation visibility is always controlled by a model. The reason behind is this behavior should not depend on implementation because changing the implementation of the [Microservice](../../Microservices/README.md) could break existing code.

This means ```ServiceOperation``` attribute has effect only on the interfaces not the implementations.

## Dto
Service Operations typically accepts [Dto](Dto.md) objects as arguments. There are several reasons for this. First, [Validation](Validation.md) is easier to implement and manage as opposed to the primitive argument types. Second, adding properties to [Dto](Dto.md) does not break existing code. Third, [Dto](Dto.md) transitions are easier because we only need to pass around a single object instead of a set of values. Next, [Dto](Dto.md) is extendable and we can control the validation with some advanced concepts which wouldn't be possible with primitive types. But the most important difference is that many [Middleware](Middlewares.md) components rely on [Dto](Dto.md) definitions. 
For example:
```csharp
public class InsertMaterialDto : Dto
{
    [Required, MaxLength(128)]
    string Name { get; set; }

    [Required, MaxLength(32)]
    string Code { get; set; }

    [NonDefault]
    DateTimeOffset Created { get; set; }

    Status Status { get; set; }
}
```
is a [Dto](Dto.md) object. If we have an Operation:
```csharp
Task<int> Insert(InsertMaterialDto dto);
```
then we can write [Validation](Validation.md) [Middleware](Middlewares.md):
```csharp
internal sealed class InsertMaterialValidator : Validator<InsertMaterialDto>
{
    protected override async Task OnInvoke()
    {
        // Validate the Dto
    }
}
```
If, on the other hand, our Service Operation would be:
```csharp
Task<int> Insert(string name, string code, DateTime created, Status status);
```
it would be impossible to implement middleware that could [Validate](Validation.md) the primitive arguments since there is nothing to attach to.

Service Operation typically accepts only one argument, which is of type ```IDto```. This is necessary since many components have constraints on ```IDto``` for various reasons so it's a good practice to follow this guideline.

## Return values
Service Operations can return values. Return values are in most cases [Entities](../Entities/README.md). Service Operations can return a single [Entity](../Entities/README.md) or an array of [Entities](../Entities/README.md).

There are of course many Service Operations where the return value is just a Task. Those Service Operations are in fact ```void``` routines.

If a Service Operation returns a single [Entity](../Entities/README.md), the return value should be ```nullable```. For example:

```csharp
Task<IMaterial?> Select(PrimaryKeyDto<int> dto);
```

The preceding code shows that Service Operation might return a ```null``` value, if the requested record is not found.

For arrays, there are two rules:
- return value should always be ```ImmutableList<T>```
- it should always return value, never a ```null```

Immutability is necessary in multi user environments, because if one client requests a data, the other might already changing it when the first is trying to read it. ```Immutable``` collections solve this challenge and prevents writes from one user to break iterators to other users. 

If an array is returned by a Service Operation and no items are available, an empty array should be returned instead of null. This is because there is no contextual difference between an empty list and null, they are both saying there are no records available. But clients would profit in that way that they don't need to check for nullability when calling Service Operations thus making code more readable.
For example:
```csharp
Task<ImmutableList<IMaterial>> Query();
```
is much better than:

```csharp
Task<ImmutableList<IMaterial>?> Query();
```
since calling the first method would looks like:

```csharp
foreach (var item in await service.Query())
{
    // Do something
}
```

instead of unnecessary null checking:

```csharp
var items = await service.Query();

if (items is not null)
{
    foreach(var item in items)
    {

    }
}
```

## Implementation

Service Operations are typically implemented in separate source files. Each file contains one Service Operation and the operations are stored in a folder **Ops**.

Service operations are always internal and they are never instantiated directly, they always come from [Dependency Injection](../DependencyInjection/README.md) container.
The following code shows how the Service Operation should be invoked from the [Service](README.md):

```csharp
public async Task<int> Insert(InsertMaterialDto dto)
{
    return await Invoke(GetOperation<Insert>(), dto);
}
```

The preceding code demonstrates the interesting feature of the ```TomPIT.Services.Service``` base class. It performs an ```Invoke``` on a Service Operation retrieved from the inline ```GetOperation```, which is a generic method which accepts Service Operation type. The ```GetOperation``` simply retrieves the Service Operation ```Service``` from [Dependency Injection](../DependencyInjection/README.md) container. Service Operations are ```Transient ``` by their nature which means every request in the [Dependency Injection](../DependencyInjection/README.md) container creates a new instance.

## Operation types
*Connected* offers two types of Service Operations:

- ```ServiceAction<TDto>```
- ```ServiceFunction<TDto, TReturnValue>```

Service Actions are effectively ```void``` methods whereas Service Functions return values.

Both types accepts a [Dto](Dto.md) argument which is never null, even for Operations that do not require a [Dto](Dto.md). For example:

```csharp
internal sealed class Query : ServiceFunction<IDto, ImmutableList<IMaterial>>
{

}
```

By accepting an ```IDto``` interface we told the *Connected* that any [Dto](Dto.md) can be passed into the Service Operation, but it will be effectively ignored regardless of its type. Invoking this Service Operations would look like:

```csharp
public async Task<ImmutableList<IMaterial>> Query()
{
    return await Invoke(GetOperation<Query>(), Dto.Empty);
}
```

## Invocation Pipeline

Service Operation invocation is a complex process which is called a pipeline. Pipeline consists of a several stages each of which can be controlled by an external set of [Middleware](Middlewares.md) components. When a [Service](README.md) performs ```Invoke``` as the preceding code shows the following pipeline is constructed:

- Service Operation is registered in the [ITransactionContext](../Data/Transactions.md)
- an ```ICallerContext``` object is created which represents a Service Operation identity 
- a [Dto Values Providers](DtoValuesProviders.md) stage is executed
- an [Ambient Providers](AmbientProviders.md) stage is executed
- a [Calibration](Calibrators.md) stage is executed
- a [Validation](Validation.md) stage is executed
- a [Service Operation Authorization](#invoke-authorization) stage is executed
- an ```Invoke``` is called
- a [Service Operation Middlewares](#operation-middlewares) are executed
- in case of Service Function the [Service Operation Result Authorization](#result-authorization) stage is executed

As you can see, a lot is happening behind the ```Invoke``` call from the [Service](README.md) so it's definitely a good idea to inherit all [Service](README.md) implementations from a ```TomPIT.Services.Service``` class.
The following code shows an example of the minimal Service Action implementation:

```csharp
internal sealed class Update : ServiceAction<UpdateMaterialDto>
{
	protected override async Task OnInvoke()
	{
		await Task.CompletedTask;
	}
}
```
The minimal Service Function would look just a little different:

```csharp
internal sealed class Insert : ServiceAction<InsertMaterialDto, int>
{
	protected override async Task<int> OnInvoke()
	{
        // Perform insert
		return result;
	}
}
```
As you can see, the Service Function returns value and the type of the returned value is indicated on two locations:

- in the declaration of the Service Operation where the second type argument is required
- in the signature of the ```OnInvoke()``` method where the same type is returned as declared 

## Authorization
By default, Authorization on Service Operations is not performed. Caller that passes the Service Authorization has full access to the Service Operation as well. In most cases this is sufficient, but there are many scenarios that an additional layer of security is needed. Service Operations offers two types of Authorization:

- access authorization
- entity authorization

Authorization is performed with a [Middleware](Middlewares.md) which differs for both scenarios. 

### Access Authorization
Access Authorization, sometimes called Invoke Authorization, is performed when we need to restrict access to the execution pipeline, before the actual ```Invoke``` is called on the Service Operation. 

> Keep in mind that Access Authorization is not the first stage in the pipeline thus you should never execute any transactions before this [Middleware](Middlewares.md) is called.

For that purpose, we implement ```IServiceOperationAuthorization<TDto>``` middleware with a decoration of```MiddlewareAttribute```. For example, let's assume we allow ```IMaterial``` entity to be inserted on *Sunday* only if an [Identity](../../Security/Identities.md) has a **Full Control** [Claim](../../Security/Claims.md).

``` csharp
[Middleware<IMaterialService>(nameof(IMaterialService.Insert))]
internal sealed class InsertMaterialAuthorization : ServiceOperationAuthorization<InsertMaterialDto>
{
	public InsertMaterialAuthorization(IAuthenticationService authentication, IClaimService claims)
	{
		Authentication = authentication;
		Claims = claims;
	}

	private IAuthenticationService Authentication { get; }
	private IClaimService Claims { get; }

	protected override async Task OnInvoke()
	{
		if (await Claims.HasFullControl(Authentication.Identity))
			return;

		if (DateTimeOffset.UtcNow.DayOfWeek == DayOfWeek.Sunday)
			throw new UnauthorizedAccessException("Only full control users can insert materials on sundays.");
	}
}
```

We took an already prepared base [Middleware](Middlewares.md) ```ServiceOperationAuthorization``` class and inherited from it. Then we requested ```IAuthenticationService``` and ```IClaimService``` from the [Dependency Injection](../DependencyInjection/README.md) container. We decorated our [Middleware](Middlewares.md) with a ```MiddlewareAttribute``` where we attached our [Middleware](Middlewares.md) to the ```IMaterialService``` and, more precisely, on the ```Insert``` Service Operation.

> Note that we must know what type of [Dto](Dto.md) the Service Operation accepts by passing the [Dto](Dto.md) type to the base class as a type argument. Failing to do it property, the [Middleware](Middlewares.md) would fail to execute.

 When the *Connected* gave as an opportunity to participate in the [Authorization](../../Security/Authorization.md) process we simply check if the [Identity](../../Security/Identities.md) has a **Full Control** [Claim](../../Security/Claims.md) by calling the extension method of the ```Membership``` [Microservice](../../Microservices/README.md).

 If any [Middleware](Middlewares.md) throws an Exception of any type, the [Authorization](../../Security/Authorization.md) fails and execution stops. 

### Entity Authorization
Access Authorization is performed before the ```Invoke``` method is called on the Service Operation. There are scenarios though where we are not able to determine if the request would be fully authorized until we receive the results of the Service Function. We call this process **Entity Authorization**.
Entity authorization is executed as part of a Service Operation but technically belongs to the [Entity](../Entities/README.md) since it is dealing with an [Entity](../Entities/README.md) instead of a Service Operation.

Entity Authorization enables us to protect sensitive records from unauthorized access. There are two behavior patterns involved:

- if a Service Function returns a single [Entity](../Entities/README.md) and Entity Authorization fails, the ```UnauthorizedAccessException``` is thrown to the caller
- is a Service Function returns a list of [Entities](../Entities/README.md), *Connected* performs [Authorization](../../Security/Authorization.md) on each [Entity](../Entities/README.md) and in the case of failed [Authorization](../../Security/Authorization.md) simply filters the [Entity](../Entities/README.md) from the result set

The [Middleware](Middlewares.md) also has the ability to change parts of the [Entity](../Entities/README.md) on the fly, for example by removing the current balance of the user account from the record, if the caller does not have sufficient privileges.
For example, let's assume only the **Full Control** [Claim](../../Security/Claims.md) can access the ```IMaterial``` with the value of the ```Code``` property of **Sensitive**:
```csharp
internal sealed class MaterialAuthorization : EntityAuthorization<IMaterial>
{
	public MaterialAuthorization(IAuthenticationService authentication, IClaimService claims)
	{
		Authentication = authentication;
		Claims = claims;
	}

	private IAuthenticationService Authentication { get; }
	private IClaimService Claims { get; }

	protected override async Task<IMaterial?> OnInvoke()
	{
		if (!string.Equals(Entity.Code, "Sensitive", StringComparison.OrdinalIgnoreCase))
			return Entity;

		if (await Claims.HasFullControl(Authentication.Identity))
			return Entity;

		var request = new RequestClaimDto
		{
			PrimaryKey = Entity.Id.ToString(),
			Identity = Authentication.Identity?.Token,
			Claims = "Read",
			Type = typeof(IMaterial).FullName
		};

		if (!await Claims.Request(request))
		{
			return new PartialMaterial
			{
				Code = "?",
				Name = Entity.Name,
				Created = Entity.Created,
				Id = Entity.Id,
				State = Entity.State
			};
		}

		return Entity;
	}
}
```
In the preceding example two important concepts are shown. First, how the [Entity](../Entities/README.md) [Authorization](../../Security/Authorization.md) actually works and the second, how we can conditionally modify the returned [Entity](../Entities/README.md) if the current [Identity](../../Security/Identities.md) does not have a sufficient privileges to access all of the [Entities'](../Entities/README.md) values.

> Note that the preceding code introduces a contradicted concept of modifying an [Entity](../Entities/README.md) outside of its Service. It's technically possible but the rule is that [Services](../Services/README.md) should never return values in the internal states, a [Cache](../Caching/README.md) for example, once they left the data source. This way, only the original implementations of the ```IMaterial``` [Entity](../Entities/README.md) is present in the [Service's](../Services/README.md) internal state.

## Service Operation Middlewares

*Connected* is highly flexible and extensible platform, ready for change in every aspect. [Core](../../Environment/Core.md) is rich in features but sometimes they don't meet customer's needs and must be extended. The common case of extending the [Core](../../Environment/Core.md) is by adding features to the existing Service Operation. For example:

```csharp
[Middleware<IMaterialService>(nameof(IMaterialService.Update))]
internal sealed class UpdateMaterialAuditTrail : ServiceActionMiddleware<UpdateMaterialDto>
{
	protected override async Task OnInvoke()
	{
		// Perform audit trail from Dt which is available in base class.
	}
}
```
To participate in the Service Execution pipeline you should implement one of two [Middlewares](Middlewares.md):

- ```ServiceActionMiddleware<TDto>```
- ```ServiceFunctionMiddleware<TDto, TReturnValue?>```

Decision depends on the type of the Service Operation and the [Dto](Dto.md) type argument must fit the Service Operation's type argument.

It's important to know that Service Operation [Middlewares](Middlewares.md) are very similar to Service Operations in that the pipeline registers them as a valid Operations which means ```Commit``` and ```Rollback``` methods are called as in the Service Operation.

## Stages

Service Operation executes inside the controlled environment which is similar to the *State Machine*. In the typical real world scenario, many Service Operation calls are made from a single client request. Service Operations can execute one after another or they can execute in parallel.

They share the same set of shared resources, of which the [Transaction](../Data/Transactions.md) context is one of the most important ones. It's hidden to the Service Operation but we still have to keep in mind how Service Operations are dependent on them. Namely, until we perform actions in the same scope and inside the ```Invoke``` routine, we and all related components which were instantiated in the same scope have access to the same resources. But, changes made in our scope, are not visible to other scopes until our scope is committed. Event more, the changed resources are very likely to be locked for access from other scopes. This way, Service Operation calls should be as short as possible to shorten the exclusive locks as much as possible. 

However, many components behave in a different manner, for example [Queues](../Collections/Queues.md), where their mission is to provide a background processing to improve user experience and system throughput. By including those concepts into Service Operations, we must take into account the challenges stated above.

Each Service Operation can be in any of the following stages:

- ```Invocation```
- ```Committed```
- ```RolledBack```

Each of the mentioned stages plays an important role in the execution pipeline.

```Invocation``` is the default stage which has been described above and all Service Operations are in this stage by default. For the other two is important to know that one and only one stage will occur after the ```Invocation```.

> You should avoid opening storage connections outside the ```Invoke``` scope since the [Transaction](../Data/Transactions.md) context already closed all open storage connections and by invoking storage operations would cause new connection to be opened which would run in an isolated mode, which means that in case of locked resources the entire stack could be a victim of a deadlock.

### Commit

If everything went as expected, the owner of the ```IContext``` will call the ```Commit``` extension method on the ```IContext``` instance. Once the ```Commit``` method is called, the scope begins to perform commits on locked resources. After the commits completed successfully, ```IContext``` turns attention to all Service Operations that have been called in the ```IContext's``` scope. They are called one after another, in the reverse order they were invoked. This means the last operation that has been invoked is the first to be committed. When the Service Operation is committed, the ```OnCommitted``` virtual method is called.

This is a perfect time to perform a clean up and to commit resources, which are not part of the shared [TransactionContext](../Data/Transactions.md). For example, if we as a part of the Service Operation logic must perform call to a remote resource, we'll probably call a commit endpoint by telling the remote source the changes made by us are valid. This concept is sometimes called two staged commits.

```csharp
protected override async Task OnCommitted()
{
    // Perform commits on external systems
    await Task.CompletedTask;
}
```

At this point, changes made by a Service Operation are already visible to other clients. But, on the other hand, we cannot reverse any changed anymore so a logic inside the ```OnCommitted``` must take this into account.

### Rollback
If any of the Service Operation calls in the execution stack thrown exception which were not property handled, the ```Rollback``` stage begins on all Service Operations, in, as is the case in ```Commit```, reverse order they were invoked. 

```csharp
protected override async Task OnRolledBack()
{
    // Perform rollback on external systems
    await Task.CompletedTask;
}
```

Once the ```OnRolledBack``` is called all changes made in the scope are already gone and no data generated in the scope is accessible.

## Set State

Changing data, being in the scope or shared, can cause big challenges to Service Operations that are invoked after the data has been changed. Deleting a record is the best example of this, namely, once the record is removed from the physical storage and memory cache, we simply don't have the access to the record anymore. If, for example, the record is part of som aggregated data model, where its quantity should be deducted from parent ```Entities```, we must have access to the entire record for solving this kind of challenge.

[Processes](../Processes/README.md) are perfect example of this since they respond to events, which typically offer only ```Id``` of the record in question and nothing more.

Luckily, *Connected* has a solution for this. Each Service Operation has two public methods, ```SetState``` and ```GetState```, which are also accessible to [EventListeners](../Processes/EventListeners.md) and some other [Middleware](Middlewares.md) components.

It's the responsibility of Service Operations to put the changed [Entity](../Entities/README.md) in its ```State``` and offer the original version to its immediate clients, such as [Event Listeners](../Processes/EventListeners.md).
```csharp
protected override async Task OnInvoke()
{
    var existing = SetState(await Materials.Select(Dto.Id) as Material);

    if (existing is null)
        throw new NullReferenceException(TomPIT.Strings.ErrEntityExpected);

    await Storage.Open<Material>().Update(existing.Merge(Dto, State.Default));
}
```
The preceding example shows how the [Entity](../Entities/README.md) is put in the Service Operation's ```State``` when read and the copy, independent of the later modification, is enabled until the Service Operation is ```Disposed```.

## Single Responsibility

A Service Operation should be responsible for only one actor, the verb that's in its name, for example, ```Insert``` or ```Update``` the ```Entity```.
By saying one actor it's meant the Service Operation should deal with just one concern. For example, ```Insert``` Service Operation will perform ```Insert``` and expects that all data required to successfully complete the Service Operation is already available, ```Validated```, ```Authorized```, ```Calibrated``` and all other Services needed are in place.