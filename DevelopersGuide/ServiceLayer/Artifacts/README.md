# Artifacts

*Connected* introduces **three** basic artifacts with whom we can model any [Microservice](../../Microservices/README.md):

- Types
- Resources
- Documents

The **fourth** artifact is not a model but rather an engine which gives artifacts the logic and runs them. This artifact is called a **Process**.

The first three artifacts are described as [Entities](../Entities/README.md).

## Types

*Types* are the most common artifact and represent a simple data structure consisted of one or more properties. *Types* are divided in two categories:

- Active
- Passive

Active *Types* differ from Passive in that they change their record set often whereas passive *Types* rarely change any value let alone a record. Most *Types* are passive. For example, a *Measure Unit* type can be defined like:

``` csharp
public interface IMeasureUnit : IEntity<int>
{
    string Name { get; set; }
    string Code { get; set; }
    Status Status { get; set; }
}
```

Once the records are inserted, they very rarely change. This is why this kind of *Type* is called a passive *Type*.

*Serial numbers* in the *Warehouse management system*, for example, change very often. In fact, on each *item* of the *Receive document* a new value is inserted. This kind of [Entities](../Entities/README.md) are active *Types*.

Types offer data structure which cannot be changed across the entire system. There are many [techniques](../../ServiceLayer/Extending/README.md) in the *Connected* to extend them, but the model of the primary [Entity](../Entities/README.md) cannot change.

Beside the data structure, *Types* don't offer any other meaningful value. They basically act as a reusable composite type used in other [Entities](../Entities/README.md), such as *Resources* and *Documents*.

*Types* can reference other *Types*, but they cannot reference *Resources* nor *Documents*.

*Types* don't have any business logic beside an ordinal input [Validation](../Services/Validation.md).

- learn more about [Types](Types.md)

### Dependencies

*Connected* does not support a technique called *Foreign Keys* on the storage level because the storage for each [Entity](../Entities/README.md) is dynamic and to leave out such an important segment from the application scope it would mean that *Connected* cannot guarantee the data consistency. 

*Connected* is an application platform that do not rely on database features too much. Most types in *Connected* are [Cached](../Caching/README.md) hence databases have lesser importance in the platform.

Dependencies exists, of course, but are handled very differently since *Connected* uses [Microservice](../../Microservices/README.md) architecture pattern which means they are dynamically plugged into the process without knowing in advance which [Microservice](../../Microservices/README.md) set will be used un runtime.

## Resources

*Resources* are very similar to types with the most notable exception that they provide one or more values that other *Resources* or *Documents* can utilize. ```IUser``` or ```IStockItem``` [Entities](../Entities/README.md) are good examples of *Resources*. ```IUser``` has availability which can be utilized when planning and ```IStockItem``` provides the quantity of the specific [Entity](../Entities/README.md) such as ```IMaterial```.

*Resources* often reference *Types* or other *Resources* but they don't reference *Documents*. They can be modeled as a complex, multi-level data structure, where their provided values are calculated or virtual but they are still regarded as *Resources* as long as they provide values that can be utilized in any form.

*Resources* don't have any business logic beside an ordinal input [Validation](../Services/Validation.md).

- learn more about [Resources](Resources.md)

## Documents

*Connected* is basically a document management system in the true sense since most business data is stored as documents. Documents are not scanned files but rather a multi-level data structures which consists of:

- *Types*
- *Resources*
- other *Documents*
- primitive values

A typical *Document* consists of a **Header** and one or more **Items**.

*Documents* provide data storage but they don't impose any predefined business logic, just like *Types* and *Resources*.

- learn more about [Documents](Documents.md)

## Processes

The main artifact in *Connected* is the *Process*. Process is a complete opposite to the other three artifacts in that it doesn't provide any data structures but it contains all business logic.

Each *Process* is dynamically plugged into a system and is fully replaceable at any time. Each process is implemented in its own [Microservice](../../Microservices/README.md). No other [Microservice](../../Microservices/README.md) must reference the *Process*.

### What Makes a Process **Process**?

*Process* is basically just a [Microservice](../../Microservices/README.md) but its component set is quite different from all other [Microservices](../../Microservices/README.md).

It typically consists of a set of [Middleware](../Services/Middlewares.md) components which control the behavior of *Documents* and *Resources*. They introduce [Validators](../Services/Validation.md), [Authorization](../../Security/Authorization.md), [Event Listeners](../Notifications/Listeners.md), [Entity Protection](../Services/EntityProtection.md) and other components that take total control of the target [Entities](../Entities/README.md).

- learn more about [Processes](Processes.md)