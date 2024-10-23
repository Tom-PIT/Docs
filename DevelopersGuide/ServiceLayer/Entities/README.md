# Entities
```Entity``` is one of the four [artifacts](../Artifacts/README.md) in the *Connected* platform. ```Entity``` represents a two dimensional data structure. It provides a set of primitive properties which together define a complex object called ```Entity```.

```Entity``` does not prescribe its behavior or storage. It is basically just a definition of the data structure. The behavior is added in the implementation which enables the *Connected* digital content to be flexible. In one environment the same ```Entity``` can have a local permanent storage but completely different in other one, a remote or virtual one, for example.

Event in the local, physical storage, which is most commonly a database, ```Entity``` does not prescribe the storage type. In one environment a storage can be Microsoft SQL Server®, but a PostGre in the other one or Oracle in the third one. Entity model in completely independent of the physical storage.

## Model

*Connected* identifies entity if it implements ```IEntity``` interface. This means that even for the most trivial data structures, which can have a single property, we should implement this interface. There are no other rules to the entities, except the [Guidelines](../../Guidelines/README.md) of which the most important is that they should be two dimensional because most relational databases would have a difficulty storing other types of data structures. 

Below is the example of the schema model.
```csharp
public interface IMaterial : IEntity
{
    string Name { get; init; }
    string Code { get; init; }

    DateTimeOffset Created { get; init; }
    DateTimeOffset? Modified { get; init; }
}
```
This is a perfect example of the entity. It's a model, not an implementation. Note that there are no attributes because the logic behind the entity is hidden from the clients because the [Services](../Services/README.md) have an exclusive access to the entity's implementation whereas the clients view only their model which is basically a data structure, nothing more.

## Foreign keys

A common relational database design is to use ```foreign keys```. It's a design which introduces dependencies on records on the database level. *Connected* does not support ```foreign keys```. There are several reasons for that.

First, *Connected* is an application platform, which means all the business logic is implemented in the application process not the database one. By introducing ```foreign keys```, two layers would do the same thing, application layer would perform a validation, and the database layer also, which is not necessary.

Next reason is that *Connected* platform does not allows user to deal with database schemas. *Connected* does it completely by itself and it does it perfectly. There is no need to create tables, manage schemas, their changes and deploy them when upgrading the system. *Connected* is fully in charge which means changes to the ```Entity``` sometimes requires database table to be recreated. If the table has dependencies this task could become very complex, sometimes even impossible to execute. We want to avoid this, of course, since manual database upgrade introduces new challenges and risks.

## Immutability

```Entities``` in *Connected* are immutable. It means once their properties are defined, they cannot change. This is why the ```init setter``` is defined in the model. It's very important concept and implementors should follow it without expections.

To learn more about immutability of the ```Entities```, read the [Immutability](Immutable.md) chapter.

## Nullability
Properties defined on ```Entities``` can be ```nullable``` which means they don't require values. This is true even for primitive property types, for example ```int``` or ```long```. A nullability is defined in the model and cannot be overridden in the implementation.

## Implementation
Implementation of the ```Entity``` defines its behavior but still not the actual storage. ```Entities``` can be virtual or permanent. If no ```Table``` attribute is set on the ```Entity's ``` implementation, it's a virtual one. The following code illustrates the virtual ```Entity```.
```csharp
internal record Tag : ITag
{
    public string Value { get; init; }
}
```
The same entity can be permanent if we define at least its schema as follows.
```csharp
[Table( Schema = "common" )]
internal record Tag : ITag
{
    public string Value { get; init; }
}
```
> [!WARNING]
> Be careful when defining the ```Table``` attribute because the attribute with the same name exists both in ```TomPIT.Annotations.Entities``` and ```TomPIT.Annotations.Models```. The latter one is from the [Shell](../../Environment/Shell.md) and *Connected* does not recognize it as a valid attribute.

- For guidelines about how to implement an ```Entity```, please read [Entities Guidelines](../../Guidelines/Entities.md).
- For more information about ```Entity``` attributes, please read [Entity Attributes](Attributes.md).

## Records

All [Core](../../Environment/Core.md) microservices follows the pattern of records instead of classes. It's not strictly necessary for ```Entities``` to be records but records have a few advantages, most notably their equality is performed on the values instead of references. Records, in ```C#```, introduces ```with``` statement where we can change existing structure with new ones in an elegant way, for example:
```csharp
var customer = existingCustomer with 
{
    Status = CustomerStatus.Disabled,
    Modified = DateTimeOffset.UtcNow
};
```
This is very useful technique for immutable data structures which ```Entities``` typically are.
## Persistence

If the ```Entity``` has a valid ```Table``` attribute specified it becomes a candidate for the automatic schema generation pipeline.
Schema is generated or updated automatically when [recompilation](../../Environment/Compilation.md) of the ```Entity``` occurs. The actual physical storage for the entity can be controlled on the ```Entity``` level which means that every ```Entity``` can have a separate type of storage.
> This scenario might seems weird at first, but the common case in *Connected* is being used in environments where database tables already exist and *Connected* must connect to the existing schemas which reside in different database servers. In these scenarios, *Connected* is the perfect choice.

Schema management is done via [Schema Providers](../Data/SchemaProviders.md) and are completely isolated from the schema implementation.

## Consistency

*Connected* is a multi user environment which means many users can compete for the same resources at the same time. It's unimaginable how difficult is to implement a reliable and consistent solutions which solves this kind of problems. Luckily, *Connected* provides all the necessary services to avoid multi user environment problems. One of the challenges is to ensure data is stored consistent and if more than one user is doing the same operation on the same entity, the system still guarantees the data consistency.

- To learn more how *Connected* ensures a consistency, please read the [Consistency](Consistency.md) chapter.

## Concurrency
Data concurrency represents a similar challenge to the data consistency with the difference that a concurrency problem occurs in the process whereas consistency on the database level. *Connected* handles this issues without any problems, for more information please read the [Concurrency](Concurrency.md) chapter.