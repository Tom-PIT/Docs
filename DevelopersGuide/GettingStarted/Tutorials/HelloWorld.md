# Tutorial: Hello World

As always, the *Hello World* example in one of the first things developers tend to do when they learn about new technology.

This tutorial is exactly that: a *Hello World*.

You will learn how to create a [Service](../../ServiceLayer/Services/README.md).

## Scenario
We want to create a Service with a single operation which will return a *Hello World* string when called.

## Microservice

First, [create](../../IDE/CreateMicroservice.md) a new microservice named **Tutorials.HelloWorld**.

## Model ```IHelloWorldService```
Add a new ```Code``` component named **IHelloWorldService** and paste the text below into the source file.
```csharp
namespace Tutorials.HelloWorld;

[Service, ServiceUrl("hello-world")]
public interface IHelloWorldService
{
   [ServiceOperation(ServiceOperationVerbs.Get)]
	Task<string> SayHello();
}
```
## Implement ```IHelloWorldService```
Add a new ```Code``` component named **HeloWorldService** and paste the text below into the source file.
```csharp
namespace Tutorials.HelloWorld;

internal sealed class HelloWorldService : Service, IHelloWorldService
{
	public HelloWorldService(IContext context) : base(context)
	{

	}

	public Task<string> SayHello()
	{
		return Task.FromResult("Hello world. It's a beautiful day, isn't it?");
	}
}
```
## Run and done
Believe it or not, you've just created a fully featured ```REST``` service, which can be called from any client supporting ```REST``` protocol.
Web browser is a most common one so let's try it. Run [Quality](../../Environment/Quality.md) environment. Open browser of your choice and enter address **[HOST]/hello-world/sayHello/**, where [HOST] is name of your host of the [Quality](../../Environment/Quality.md) instance.
The browser will display **"Hello world. It's a beautiful day, isn't it?"**.

## Summary
This wasn't hard, wasn't it? In fact, no task is hard in the *Connected*, event if your environment is an extremely demanding one. By following *Connected* best practices and [guidelines](../../Guidelines/README.md) and with the help of tons of services, components and tools *Connected* provides, you'll be able to solve complex business problems in virtually no time.

Welcome again to the exciting world of *Tom PIT.connected*.
