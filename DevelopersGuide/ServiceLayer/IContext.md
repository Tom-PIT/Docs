# IContext and IContextProvider
*Connected* uses [Dependency Injection](https://en.wikipedia.org/wiki/Dependency_injection) (DI) technique to achieve separation of concerns.
DI is based on Scopes and, behind the scene, it's a complex process that orchestrates the processes, states and different pipelines.

Services are placed in the DI Container on system [startup](../Environment/Startup.md) from where they are later accessible to clients.

*Connected*, like .NET, offers three different types of Services:
- ```Singleton```
- ```Scoped```
- ```Transient```

*Connected* sets a few very basic rules when designing a *Connected* service model.

```Singleton``` services are services for whose only one instance is created and shared across all clients. ```Scoped``` services are instantiated once for every scope and the ```Transient``` services are instantiated for every single service request.
```Transient``` services can depend on ```Scoped``` and ```Singleton``` services but ```Scoped``` and ```Singleton``` services cannot depend on ```Transient``` ones. The same is rule applies to the ```Scoped``` services; they cannot depend on ```Transient``` but can use ```Singleton```. Eventually, ```Singleton``` services can use only other ```Singleton``` services.

## Scoped
In fact, the most *Connected* [Services](Services/README.md) are scoped. This means they share the same resources inside the same scope, for example the [Cache](Caching/README.md) or storage [Transactions](Data/Transactions.md).

[Service Operations](../ServiceLayer/Services/Operations.md) are ```Transient``` which means you shouldn't save any state inside them because they get disposed immediately after their use.

All [Middleware](Services/Middlewares.md) components are also ```Transient``` but you don't have to really worry about their registration since they are registered automatically on [startup](../Environment/Startup.md).

## IContext
In *Connected*, scope is managed by a service called ```IContext``` defined in the ```TomPIT.Services``` namespace. ```IContext``` is not created automatically and must be instantiated and controlled manually.

Luckily, you will very rarely have to deal with the creation of ```IContext``` directly since this is already done on all important endpoints, for example [RequestServiceDelegate](https://connected.tompit.com/repositories?folder=Repositories%252FTom%2520PIT&document=116&type=Repository) on REST endpoints or [QueueHost](https://connected.tompit.com/repositories?folder=Repositories%252FTom%2520PIT&document=102&type=Repository) components.

```IContext``` is disposable and its lifetime should be carefully managed since it can hold an exclusive access to many system resources and can often hold database locks or other kind of system critical operations.

This is why ```IContext``` plays a fundamental role in the *Connected* platform since it's the parent to virtually all [Services](Services/README.md) except the ```Singleton``` ones.

## Creating ```IContext```
```IContext``` can't be created directly, in fact it's the ```IContextProvider``` which provides this feature. ```IContextProvider``` is a ```Singleton``` service which is directly accessible via DI ```IServiceProvider```. In *Connected*, the most common case to retrieve an ```IServiceProvider``` is via ```Startup ``` component. 

The following code illustrates how the ```IServiceProvider``` can be made available inside the entire microservice.

```csharp
using TomPIT.Runtime;

namespace Example;

internal sealed class Bootstrapper : Startup
{
	public static IServiceProvider? Provider { get; private set; };

	protected override async Task OnInitialize()
	{
		Provider = Services;

		await Task.CompletedTask;
	}
}
```
```IServiceProvider``` is not directly exposed from the [Startup](../Environment/Startup.md) component, but we can make it accessible once it becomes available which is ```OnInitialize``` method of the [Startup](../Environment/Startup.md) process. 

For more information about bootstrapping the microservice please read the [Startup](../Environment/Startup.md) chapter.

Once we have a static ```IServiceProvider``` available, we can access it inside any code within microservice. For example:
```csharp
var provider = Bootstrapper.ServiceProvider?.GetRequiredService<IContextProvider>();
using var context = provider.GetService<IContext>();

try
{
    /*  
     * Do some stuff
     */
    await context.Commit();
}
catch
{
    await context.Rollback();
}
```
Keep in mind that code which instantiates the ```IContext``` manages its life cycle. By calling ```Commit``` or ```Rollback``` extension methods respectively, the ```IContexts'``` lifecycle ends. Those two methods are very expensive thus they must be called as soon as possible.
### ```Commit```
When an ```IContext``` commits the changes made are committed to the system resources. This includes the [Saga](Data/Saga.md) transactions orchestration is activated and the changes in the [Cache](Caching/README.md) are committed from the scoped to the shared memory.
```Commit``` should be called only once per ```IContext```.
### ```Rollback```
If something unexpected occurs we might want to cancel all changes made in the current scope. By calling a ```Rollback``` *Connected* will try to undo everything what happened in the current scope. 
```Rollback``` can be called only once. Any subsequent calls would have no effect on the ```IContext```.