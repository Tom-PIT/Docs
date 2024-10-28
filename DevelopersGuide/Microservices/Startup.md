# Startup

If a [Microservice](README.md) want to participate in the Startup process it must implement a ```class``` which inherits from the [Shell's](../Environment/Shell.md) ```Startup``` class. We typically put this class in the root and name it **Bootstrapper.cs**.

*Connected* looks in each [Microservice](../Microservices/README.md) for this implementation and if exists it adds it in the Startup Queue. You can control the order of the execution by decorating a class with a ```Priority``` attribute.

There are four stages in the Startup process:

- ConfigureServices
- Configure
- Initialize
- Start

Stages occur in the exact order as stated above. The following code shows a model for the Startup:
```csharp
namespace TomPIT.Runtime;

public interface IStartup
{
	void ConfigureServices(IServiceCollection services);
	void Configure(IApplicationBuilder app, IWebHostEnvironment env);
	Task Initialize(IHost host);
	Task Start();

	bool HasRecompiled { get; }
}
```

Technically, you can implement this interface directly but a more elegant way is to inherit from a default implementation which is also available from the same ```namespace```:
```csharp
namespace TomPIT.Runtime;

public abstract class Startup : IStartup
{
    ...
}
```
## Configure Services

Most *Connected* components are registered automatically if you don't change the default behavior. However, there are scenarios you want to register additional components or register components that are not automatically registered by a *Connected*. For example:

```csharp
	protected override void OnConfigureServices(IServiceCollection services)
	{
		services.AddLogging(builder => builder.AddConsole());
	}
```
The preceding code shows how to add a ```Console``` logger to the services configuration.

The **TomPIT.Core.Configuration** [Microservice](../Microservices/README.md) uses this opportunity to automatically register components of each registered [Microservice](../Microservices/README.md).

## Configure

Configuring stage is executed after all services are added to the [Dependency Injection](../ServiceLayer/DependencyInjection/README.md) container. This is the right moment to configure custom services, for example:

```csharp
	protected override void OnConfigure(IApplicationBuilder app, IWebHostEnvironment env)
	{
		app.UseMiddleware<AuthenticationCookieMiddleware>();
	}
```

## Initialize

Once the [Shell](../Environment/Shell.md) reaches the ```Initialize``` stage all services are registered and configured and the system is pretty much up and running. At this point we can already request services from the [Dependency Injection](../ServiceLayer/DependencyInjection/README.md) container or initialize custom services with the fully enabled features. 

The common example on the ```Initialize``` implementation is to dereference ```IServiceProvider``` and make it visible inside the [Microservice](../Microservices/README.md). ```IServiceProvider``` is not set before this stage so this is the best opportunity to do it, for example:
```csharp
internal sealed class Bootstrapper : Startup
{
	public static IServiceProvider? ServiceProvider{ get; private set; }

	protected override async Task OnInitialize()
	{
		ServiceProvider = Services;

		await Task.CompletedTask;
	}
}
```
## Start

The last stage before the system becomes accessible to clients is ```Start```. In the ```Start``` stage are performed tasks that need [Microservices](../Microservices/README.md) to be fully functional, initialized and ready to use without conditions.

For example, **TomPIT.Core.Model** uses this stage to synchronize storage schemas for the recompiled [Microservices](../Microservices/README.md):

```csharp
namespace TomPIT;

internal sealed class Bootstrapper : Startup
{
	protected override async Task OnStart()
	{
		await SynchronizeSchemas();
	}

	private async Task SynchronizeSchemas()
	{
        ...
	}
}
```
## HasRecompiled

Startup class convenient property called ```HasRecompiled``` which tells us if our [Microservice](../Microservices/README.md) has [Recompiled](../Environment/Compilation.md) on [Startup](../Environment/Startup.md). Namely, *Connected* performs [Compilation](../Environment/Compilation.md) in the process instead of expecting the binaries to be available on startup.

With the help of this property we can do some maintenance tasks, such as data migration or automatically set some setting values if they are not present.

> Note that a recompilation can occur even if the [Microservice](../Microservices/README.md) does not contain any code changes. Recompilation of any dependency will cause the [Microservice](../Microservices/README.md) will recompile as well.