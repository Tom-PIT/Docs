# Services 
Service is one of the most important building blocks of the [Microservice](../../Microservices/README.md). Services manipulates with [Entities](../Entities/README.md) and each [Entity](../Entities/README.md) should be managed by exactly one Service.
In *Connected*, everything is a Service. Services are placed in [Dependency Injection](../../ServiceLayer/DependencyInjection/README.md) container and can be ```Singleton```, ```Scoped``` or ```Transient```. They are created and managed by [IContext](../../ServiceLayer/IContext.md) with the exception of ```Singleton``` services.

Service consists of one or more [Service Operations](Operations.md). Operations serve as a single processing unit solving a single business challenge.

## Model

Service is defined with a ```ServiceAttribute``` attribute. Any ```interface``` which is decorated with this attribute will *Connected* recognize as a perfectly valid service. For example:
```csharp
[Service]
public interface IMaterialService
{

}
```
The preceding code demonstrates a service model, sometimes called contract. It's not an implementation, of course, it's just a model to which other services can reference. Modeling is typically done in separate [Microservices](../../Microservices/README.md) from their respective implementations. *Connected* has a great ability to dynamically merge microservices in runtime which means implementation [Microservices](../../Microservices/README.md) can be replaced without affecting and other [Microservice](../../Microservices/README.md) since they refer to each other via models instead of implementations.

## Service Scope
By default, when the implemented Service gets registered in the [Dependency Injection](../DependencyInjection/README.md) container, it is registered as a ```Scoped``` Service. Scope can be controller inside the ```ServiceAttribute``` by using one of the overloaded constructors and set its ```Scope``` property. For example:
```csharp
[Service(ServiceRegistrationScope.Transient)]
public interface IMaterialService
{

}
```
The preceding code demonstrates how the Service can be registered as ```Transient```
> Change the default ```Scope``` very carefully since the implementation can depend of other services. Making Service ```Scope``` a ```Singleton``` would make implementors unable to use ```Scoped``` and ```Transient``` services.
## Access Modifiers

By default, Services are not accessible from external clients. To enable external access, decorate Service with another attribute, named ```ServiceUrlAttribute``` which accepts a single parameter in constructor, an ```Url```. For example:
```csharp
[Service, ServiceUrl("services/common-types/materials")]
public interface IMaterialService
{

}
```
By decorating the service with a ```ServiceUrlAttribute``` attribute, clients can access the service via different protocols of whose REST is the most common and is supported out of the box. In the preceding example, the service would be accessible from **[HOST]://services/common-types/materials** url, where [HOST] is in the form **https://www.tompit.com**.

It's a good practice to prefix service urls with **service** string. For more information, read the [NamingGuidelines](../../Guidelines/NamingGuidelines.md).

The visibility of Service itself and its Operations are always controlled in a model thus making this behavior independent of the implementation. Decorating implementation components with attributes above have no impact in the runtime.

## Implementation

Services are typically implemented in extern, conditionally included [Microservices](../../Microservices/README.md). This implementation pattern is very important since it allows implementations to be replaced without the need to change this model code to which other [Microservices](../../Microservices/README.md) have references to.

Technically, there are no special requirements when implementing a Service. For example:

```csharp
internal sealed class MaterialService : IMaterialService
{

}
```
This is a perfectly fine from the *Connected* point of view. On [Start](../../Environment/Startup.md), the Service will get automatically registered in the [Dependency Injection](../DependencyInjection/README.md) container.

However, from the architecture point of view, the Service should inherits from ```Service``` base class from the ```TomPIT.Services``` namespace.
```csharp
internal sealed class MaterialService : Service, IMaterialService
{
    public MaterialService(IContext context): base(context)
    {

    }
}
```
By inheriting a ```MaterialService``` from a ```Service``` base class we get all the features we need for [Operations](Operations.md) invocation.

The preceding code shows the ```Service``` base class expects ```IContext``` to be passed to the constructor. The ```IContext``` represents a [Dependency Injection](../DependencyInjection/README.md) scope and all invoked operations are instantiated from the passed ```IContext```.

## Registering Services
By default, all Services are automatically registered in the [Dependency Injection](../DependencyInjection/README.md) container as ```Scoped``` services. Sometimes, however, we want a different behavior. To control this, set the ```ServiceRegistrationAttribute``` in the Service level as the following code shows:
```csharp
[ServiceRegistration(ServiceRegistrationMode.Manual)]
internal sealed class MaterialService : Service, IMaterialService
{
    public MaterialService(IContext context): base(context)
    {

    }
}
```
This way, we told the *Connected* to skip the registration of the Service. Note that we must decorate implementation not model with this ```attribute```.
The registration process is now left to the developer. The following code shows how we could register the Service manually:
```csharp
internal sealed class Bootstrapper : Startup
{
    protected override void OnConfigure(IServiceCollection services)
    {
        services.AddTransient<IMaterialService, MaterialService>();
    }
}
```
The preceding code shows how we can manually register the Service with a ```Transient``` scope.

## Authorization

By default, Service access is limited to the authenticated clients. You can, of course, change this behavior for every Service. Service authorization is managed by ```IServiceAuthorization``` [Middleware](../Services/Middlewares.md). Service authorization is part of the *Connected* [Authorization](../../Security/Authorization.md) scheme.
For example:
```csharp
using TomPIT.Authentication;

[Middleware<IMaterialService>]
internal sealed class MaterialServiceAuthorization : ServiceAuthorization
{
    public MaterialServiceAuthorization(IAuthenticationService authentication)
    {
        Authentication = authentication;
    }

    private IAuthenticationService Authentication { get; }

    protected override async Task OnInvoke()
    {
        // Perform authorization logic
    }
}
```
The preceding code shows how to implement and attach the [Middleware](Middlewares.md) to the correct service. By decorating the service with ```Middleware``` attribute we instructed the *Connected* that we want to participate in the ```IMaterialService``` service. By inheriting from ```ServiceAuthorization``` we instructed *Connected* that the [Middleware](Middlewares.md) should be run as part of the [Authorization](../../Security/Authorization.md) process on the Service level.

You have access to two important properties, ```Dto``` and ```Caller```. ```Dto``` property holds the reference to the actual ```Dto``` instance which will be passed into [Service Operation](Operations.md) call and ```Caller``` contains data about ```Sender``` and ```Method```. The ```Sender``` property holds reference to the instance of the Service, in this case ```MaterialService```. The ```Method``` is the actual method called which contextually means the [Service Operation](Operations.md).

This way, you have a total control of the authorization process regardless of the complexity.