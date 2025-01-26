# Tutorial: Get Started with Tom PIT.connected

This tutorial shows how to create a fully featured service with all the necessary operations for manipulating a single entity [Entity](../../ServiceLayer/Entities/README.md).

You will learn how to:
- model a Microservice
- implement [Service Layer](../../ServiceLayer/README.md)
- run [Microservice](../../Microservices/README.md)

At the end of this tutorial, you'll have a working ```Customer``` entity with *CRUD* operations, caching and event broadcasting support, features found in most [Core](../../Environment/Core.md) Microservices.

> Source code for this tutorial is available in the [Tutorials Repository](https://github.com/Tom-PIT/Tutorials/tree/main/Customers).

## Scenario

We want to create a server application containing a Microservice for managing a ```Customer``` entity. ```Customers``` need to be stored in the database and all operations must be accessible via ```REST``` services.

## Model

First, [create](../../IDE/CreateMicroservice.md) a new *Class Library* Microservice named **Connected.Academy.Customers.Model**, with a package reference to ```Connected.Sdk```. Paste the following into the ```csproj``` file just before the first closing ```</PropertyGroup>``` element:

``` xml
<RootNamespace>Connected.Academy.Customers</RootNamespace>
```

### Customers Entity Model
Add a new class named **ICustomer** and paste the following code into it:

``` csharp
using Connected.Entities;

namespace Connected.Academy.Customers;

public interface ICustomer : IEntity<int>
{
    string FirstName { get; init; }
    string LastName { get; init; }
}
```

```ICustomer``` serves as the [Entity](../../ServiceLayer/Entities/README.md) model of a Microservice.

### Dtos
[Dto](../../ServiceLayer/Services/Dto.md) object serve as a transport object containing only a properties without any business logic. We always send *Dto* objects into service calls instead of *Entities*. First, create a new folder named **Dtos** and then add a new class named **ICustomerDto** and paste the following code into it:

``` csharp
using Connected.Services;

namespace Connected.Academy.Customers.Dtos;

public interface ICustomerDto : IDto
{
    string FirstName { get; set; }
    string LastName { get; set; }
}
```
Add another class in the same folder named **IInsertCustomerDto** and paste the following code into it:

``` csharp
namespace Connected.Academy.Customers.Dtos;

public interface IInsertCustomerDto : ICustomerDto
{
}
```

and finally add another class named **IUpdateCustomerDto** with the following code:

``` csharp
using Connected.Services;

namespace Connected.Academy.Customers.Dtos;

public interface IUpdateCustomerDto : IPrimaryKeyDto<int>, ICustomerDto
{

}
```

### MetaData

Add a new class under the project root named **CustomersMetaData** and paste the following code into it:

``` csharp
using System;

namespace Connected.Academy.Customers;

public static class CustomersMetaData
{
    private const string Namespace = "services/academy";
    public const string CustomerServiceUrl = $"{Namespace}/customers";
    public const string CustomersEntityKey = $"{Schema}.{nameof(ICustomer)}";
    public const string Schema = "academy";
}
```
### ICustomerService

The last interface we'll add to the model is a service itself. Add a new class named **ICustomerService** and paste the following code into it:

``` csharp
using System.Collections.Immutable;
using Connected.Academy.Customers.Dtos;
using Connected.Annotations;
using Connected.Services;

namespace Connected.Academy.Customers;

[Service, ServiceUrl(CustomersMetaData.CustomerServiceUrl)]
public interface ICustomerService
{
    [ServiceOperation(ServiceOperationVerbs.Put)]
    Task<int> Insert(IInsertCustomerDto dto);

    [ServiceOperation(ServiceOperationVerbs.Post)]
    Task Update(IUpdateCustomerDto dto);

    [ServiceOperation(ServiceOperationVerbs.Delete)]
    Task Delete(IPrimaryKeyDto<int> dto);

    [ServiceOperation(ServiceOperationVerbs.Get)]
    Task<IImmutableList<ICustomer>> Query(IQueryDto? dto);

    [ServiceOperation(ServiceOperationVerbs.Get)]
    Task<ICustomer?> Select(IPrimaryKeyDto<int> dto);
}
```
## The ```Customer``` Microservice implementation

We've a complete model for the ```Customer``` Microservice which can be referenced by other Microservices. Let's implement the service with all necessary components. First, create new project named **Connected.Academy.Customers** and add package reference to the ```Connected.Sdk``` and project reference to the ```Connected.Academy.Model```. Create two folders, named **Dtos** and **Ops**.

### Customer Entity
Add a new class named **Customer** and paste the following code into it:
``` csharp
using Connected.Annotations;
using Connected.Annotations.Entities;
using Connected.Entities;

namespace Connected.Academy.Customers;

[Table(Schema = CustomersMetaData.Schema)]
internal sealed record Customer : ConsistentEntity<int>, ICustomer
{
    [Ordinal(0), Length(32)]
    public required string FirstName { get; init; }

    [Ordinal(1), Length(64)]
    public required string LastName { get; init; }
}
```
This is the actual ```Customer``` data structure with persistent storage.

### The cache

Suppose we want to cache all customers in the cache for faster access. We'll implement ```IEntityCache``` which automatically provides all the necessary features for loading and refreshing entities from the database.
Add a new class named ```ICustomerCache``` and paste the following code into it:
``` csharp
using Connected.Caching;

namespace Connected.Academy.Customers;

internal interface ICustomerCache : IEntityCache<Customer, int>
{

}
```

The interface is not mandatory but it will be easier to write unit tests if you not rely on the actual interface implementation.
Now, let's implement the cache by adding another class named ```CustomerCache``` with the following code:

``` csharp
using Connected.Caching;
using Connected.Storage;

namespace Connected.Academy.Customers;

internal sealed class CustomerCache(ICachingService cache, IStorageProvider storage)
    : EntityCache<Customer, int>(cache, storage, CustomersMetaData.CustomersEntityKey), ICustomerCache
{
}
```

### Dtos
We now have to implement ```Dto``` objects. Add class named **CustomerDto** in the **Dtos** folder with the following code:

``` csharp
using System.ComponentModel.DataAnnotations;
using Connected.Services;

namespace Connected.Academy.Customers.Dtos;

internal abstract class CustomerDto : Dto, ICustomerDto
{
    [Required, MaxLength(32)]
    public required string FirstName { get; set; }

    [Required, MaxLength(64)]
    public required string LastName { get; set; }
}
```

This class serves only for the base class purposes hence the abstract modifier. Now add another class named **InsertCustomerDto** and paste the following code into it:

``` csharp
namespace Connected.Academy.Customers.Dtos;

internal sealed class InsertCustomerDto : CustomerDto, IInsertCustomerDto
{

}
```

Similarly, add another class named **UpdateCustomerDto** with the following code:

```csharp
using Connected.Annotations;

namespace Connected.Academy.Customers.Dtos;

internal sealed class UpdateCustomerDto : CustomerDto, IUpdateCustomerDto
{
    [MinValue(1)]
    public int Id { get; set; }
}
```

### The Customer Service

Now let's add a class named **CustomerService** with the following code:

```csharp
using System.Collections.Immutable;
using Connected.Academy.Customers.Dtos;
using Connected.Academy.Customers.Ops;
using Connected.Services;

namespace Connected.Academy.Customers;

internal sealed class CustomerService(IServiceProvider services) : Service(services), ICustomerService
{
    public async Task Delete(IPrimaryKeyDto<int> dto)
    {
        await Invoke(GetOperation<Delete>(), dto);
    }

    public async Task<int> Insert(IInsertCustomerDto dto)
    {
        return await Invoke(GetOperation<Insert>(), dto);
    }

    public async Task<IImmutableList<ICustomer>> Query(IQueryDto? dto)
    {
        return await Invoke(GetOperation<Query>(), dto ?? QueryDto.NoPaging);
    }

    public async Task<ICustomer?> Select(IPrimaryKeyDto<int> dto)
    {
        return await Invoke(GetOperation<Select>(), dto);
    }

    public async Task Update(IUpdateCustomerDto dto)
    {
        await Invoke(GetOperation<Update>(), dto);
    }
}
```

At this point the project won't compile because we don't have operations yet.

### Ops
Add a class in the folder **Ops** named **Delete** and paste the following code into it:

```csharp
using Connected.Entities;
using Connected.Notifications;
using Connected.Services;
using Connected.Storage;

namespace Connected.Academy.Customers.Ops;

internal sealed class Delete(IStorageProvider storage, IEventService events, ICustomerService customers, ICustomerCache cache)
    : ServiceAction<IPrimaryKeyDto<int>>
{
    protected override async Task OnInvoke()
    {
        _ = SetState(await customers.Select(Dto)) as Customer ?? throw new NullReferenceException(Strings.ErrEntityExpected);

        await storage.Open<Customer>().Update(Dto.AsEntity<Customer>(State.Deleted));
        await cache.Remove(Dto.Id);
        await events.Deleted(this, customers, Dto.Id);
    }
}
```
This class will perform the ```Delete``` operation on the ```Customer``` Entity.
Add another class named **Insert** with the following code:

```csharp
using Connected.Academy.Customers.Dtos;
using Connected.Entities;
using Connected.Notifications;
using Connected.Services;
using Connected.Storage;

namespace Connected.Academy.Customers.Ops;

internal sealed class Insert(IStorageProvider storage, IEventService events, ICustomerService customers, ICustomerCache cache)
    : ServiceFunction<IInsertCustomerDto, int>
{
    protected override async Task<int> OnInvoke()
    {
        var entity = await storage.Open<Customer>().Update(Dto.AsEntity<Customer>(State.New)) ?? throw new NullReferenceException(Strings.ErrEntityExpected);

        await cache.Refresh(entity.Id);
        await events.Inserted(this, customers, entity.Id);

        return entity.Id;
    }
}
```
The class above contains all the necessary logic to insert a customer, put it in the cache and trigger the distributed event notifying clients that a new customer has been inserted.

Now add another class named **Update** and paste the following code into it:

```csharp
using Connected.Academy.Customers.Dtos;
using Connected.Entities;
using Connected.Notifications;
using Connected.Services;
using Connected.Storage;

namespace Connected.Academy.Customers.Ops;

internal sealed class Update(IStorageProvider storage, IEventService events, ICustomerService customers, ICustomerCache cache)
    : ServiceAction<IUpdateCustomerDto>
{
    protected override async Task OnInvoke()
    {
        var entity = SetState(await customers.Select(Dto)) as Customer ?? throw new NullReferenceException(Strings.ErrEntityExpected);

        await storage.Open<Customer>().Update(entity.Merge(Dto, State.Default), Dto, async () =>
        {
            await cache.Refresh(Dto.Id);

            return SetState(await customers.Select(Dto)) as Customer ?? throw new NullReferenceException(Strings.ErrEntityExpected);
        }, Caller);

        await cache.Refresh(Dto.Id);
        await events.Updated(this, customers, Dto.Id);
    }
}
```

This is the most complex operation because it handles the data [Consistency](../../ServiceLayer/Entities/Consistency.md) when performing an ```Update```.

Add another class named **Query** with the following code:

```csharp
using System.Collections.Immutable;
using Connected.Entities;
using Connected.Services;

namespace Connected.Academy.Customers.Ops;

internal sealed class Query(ICustomerCache cache)
    : ServiceFunction<IQueryDto, IImmutableList<ICustomer>>
{
    protected override async Task<IImmutableList<ICustomer>> OnInvoke()
    {
        return await cache.AsEntities<ICustomer>();
    }
}
```

As you can see it's really a trivial task to retrieve all customers. In our case customers are loaded from the cache but we would write virtually identical syntax if we would read the customers directly from the database. In our case it's the ```IEntityCache``` that did the job for us.

Add another class named **Select** with the following code:

```csharp
using Connected.Entities;
using Connected.Services;

namespace Connected.Academy.Customers.Ops;

internal sealed class Select(ICustomerCache cache)
    : ServiceFunction<IPrimaryKeyDto<int>, ICustomer?>
{
    protected override async Task<ICustomer?> OnInvoke()
    {
        return await cache.AsEntity(f => f.Id == Dto.Id);
    }
}
```
Similar to the ```Query``` operation the ```Select``` operation read a specified ```Customer``` from the case by performing a ```LINQ``` operation.

## The application
The last task in this tutorial is to run the ```CustomerService```. Create another *Console App* project named **Connected.Academy.App** with a package reference to ```Connected.Runtime``` and project reference to ```Connected.Academy.Customers```. 

> [!NOTE]
> Please follow the steps in the [Create Microservice](CreateMicroservice.md) how to configure **appsettings.json** file.

Open **Program.cs** and replace file with the following code:

```csharp
using Connected;

Application.RegisterMicroService("Connected.Academy.Customers.dll");

await Application.StartDefaultApplication(args);
```
Run the program. If you look into a database you will see that *Connected* automatically created a new table named ```academy.customer```. 

Now let's start a program for testing REST endpoints, for example [Postman](https://www.postman.com/) and test the following urls:

```
- http://localhost:5000/services/academy/customers/query
- http://localhost:5000/services/academy/customers/insert
- http://localhost:5000/services/academy/customers/update
- http://localhost:5000/services/academy/customers/delete
- http://localhost:5000/services/academy/customers/select
```
For the ```insert``` endpoint pass the following ```json``` body:

```json
{
    "firstName":"John",
    "lastName": "Joe"
}
```

For the ```update``` endpoint pass the following ```json``` body:

```json
{
    "firstName":"Mick",
    "lastName": "Jagger",
    "id": 1
}
```

For the ```delete``` and ```select``` endpoint pass the following ```json``` body:

```json
{
    "id": 1
}
```

## Summary
**Congratulations!** You've just implemented the very basic Microservice of the *Connected* platform. You are now ready to learn more advanced concepts to be ready to complete real world tasks as soon as possible.