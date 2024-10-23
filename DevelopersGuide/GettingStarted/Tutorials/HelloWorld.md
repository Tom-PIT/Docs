# Tutorial: Get Started with Tom PIT.connected
This tutorial shows how to create a fully featured service with a simple user interface.

You will learn how to create:
- model microservice
- entity
- service
- client service
- UI components
- view

At the end, you'll have a working Customer entity with CRUD operations on the user interface.

## Scenario
We want to create an entity which represents a customer. We need a data structure for storing data, a service for manipulating data and client for interactive use of the data.

## Microservices
For this scenario we'll need to create 4 microservices:
- Tutorial.Customer.Model
- Tutorial.Customers
- Tutorial.Customers.JS
- Tutorial.Customers.Views

> Technically it's not necessary to create 4 microservices, we could put all source code in one microservice, but by following the *Connected* guideline, 4 microservices are recommended. This way, we'll have loosely coupled sistem where and microservices (except the model) can be replaced at any time.

## Creating a model microservice
First, we are going to create model. Model consists of an entity and a service. 
- in *Connected* IDE, navigate to the microservices, located at sys/development/local/microservices url under your host 
- click on the plus button at the bottom right corner
- the create microservice screen shows up. Click **Create from scratch** button
- enter **Tutorial.Customer.Model** in the *name* text box
- click **Create** button
- a *Connected* IDE shows up with a newly created workspace

We are now ready to start coding.

## Create Entity
We'll define an entity which will represent a ```Customer```.
Add a new *Code* component and name it ```ICustomer```.
Enter the following code in the source file:
```csharp
using TomPIT.Entities;

namespace Tutorial.Customer;

public interface ICustomer : IEntity<int>
{
	string Name { get; init; }
}
```
We have just defined a ```Customer``` entity, which has an ```Id``` property of the type ```int``` and a ```string``` property, which represents its name.

## Create ```ICustomerService```
Now that we have an *Entity* defined, we must create a model for its service. Service consists of operations where each operation typically accepts one argument which is called a ```Dto```. ```Dto``` stands for **Data transformation object** and its purpose is to move data from one endpoint to another. It never contains any business logic, only properties and their respective validation attributes.

```Customer``` service will contain the following methods:
- ```Insert```, for adding new customers
- ```Update```, for modifying existing customer
- ```Delete```, for deleting an existing customer
- ```Query```, for querying customers
- ```Select```, for selecting a single customer

*Connected* guideline expects ```Dto``` objects to be located in the *Dto* folder. Create a new folder named **Dto**.

Now we are ready to create ```Dto``` objects. Add a new *Code* component with a name **InsertCustomerDto** in the folder **Dto**. Paste the following code in the source file:
```csharp
using System.ComponentModel.DataAnnotations;
using TomPIT.Services;

namespace Tutorial.Customer;

public class InsertCustomerDto : Dto
{
	[Required, MaxLength(128)]
	public string Name { get; set; } = default!;
}
```

This ```Dto``` will be used when inserting a new ```Customer```. Note that we require the ```Name``` property to be specified with a ```Required``` attribute and we allow the value to be at most 128 characters long. Attribute validation is done automatically in *Connected*.

The second ```Dto``` is for updating an existing customer. Add another ```Code``` component and name it **UpdateCustomerDto** and paste the following code into it:
```csharp
using System.ComponentModel.DataAnnotations;
using TomPIT.Annotations;
using TomPIT.Services;

namespace Tutorial.Customer;

public class UpdateCustomerDto : Dto
{
	[MinValue(1)]
	public int Id { get; set; }

	[Required, MaxLength(128)]
	public string Name { get; set; } = default!;
}
```

```UpdateCustomerDto``` is very similar to the ```InsertCustomerDto``` with the exception it contains an id of the ```Customer```.

For the simple entities like ```Customer``` two ```Dto``` object are sufficient.

Now let's create an ```ICustomerService```.

Add *Code* Component with a name ```ICustomerService``` and paste the following code into it:
```csharp
using System.Collections.Immutable;
using TomPIT.Annotations;
using TomPIT.Services;
using System.Threading.Tasks;

namespace Tutorial.Customer;

[Service, ServiceUrl("services/customers")]
public interface ICustomerService
{
	[ServiceOperation(ServiceOperationVerbs.Put | ServiceOperationVerbs.Post)]
	Task<int> Insert(InsertCustomerDto dto);

	[ServiceOperation(ServiceOperationVerbs.Post)]
	Task Update(UpdateCustomerDto dto);

	[ServiceOperation(ServiceOperationVerbs.Delete | ServiceOperationVerbs.Post)]
	Task Delete(PrimaryKeyDto<int> dto);

	[ServiceOperation(ServiceOperationVerbs.Get | ServiceOperationVerbs.Post)]
	Task<ImmutableList<ICustomer>> Query(QueryDto? dto);

	[ServiceOperation(ServiceOperationVerbs.Get | ServiceOperationVerbs.Post)]
	Task<ICustomer?> Select(PrimaryKeyDto<int> dto);
}
```
At this point, we have complete a model for a *Customer* microservice. This way, any microservice requiring an ```ICustomer``` entity can reference this model without knowing what implementation will be available in the runtime.
## Customers microservice
We have a model defined, now we need to implement it. An implementation can be very specific, from retrieving a customer set from a remote service, to being a completely virtual or a default one, to implement a permanent storage.

Create a new microservice named **Tutorial.Customers**.
1. [Add Reference](https://github.com/Tom-PIT/Docs/blob/main/DevelopersGuide/IDE/AddReference.md) to ```Tutorial.Customer.Model``` 
2. Add a new Folder named **Ops**. This folder will contain all service operations implementations.
3. Add a new ```Code``` Component  on the root named **CustomerService**.
