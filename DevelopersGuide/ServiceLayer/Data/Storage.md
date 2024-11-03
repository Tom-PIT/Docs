# Storage

*Connected* provides a complete set of services that manages the storage. Storage is not all about databases, but can also means a remote storage, a file system or an email box. Whenever we think of an [Entity](../Entities/README.md) that needs to be stored permanently or are simply virtual, we are talking of *Storage*.

## Physical Storage

In *Connected*, we don't really have to deal too much with the storages. We never touch the databases, there is absolutely no need for that since *Connected* takes care of all the complexities regarding schemas and I/O operations.

Most [Entities](../Entities/README.md) are permanently stored. The most common permanent *Storage* is database. A bridge between an [Entity](../Entities/README.md) and a physical storage is [Storage provider](StorageProviders.md) which provides the services needed for reading data, writing data and managing schemas. Every [Entity](../Entities/README.md) can have it own storage provider. This means that an [Entity](../Entities/README.md) **A** can be stored in a *Microsoft SQL Server* but [Entity](../Entities/README.md) **B** can be stored in a *PostgreSQL*. By implementing one of the storage related [Middleware](../Middleware.md) components you can have a fine grained control of which [Entities](../Entities/README.md) will be stored where. The most important [Middleware](../Middleware.md) components are:

- ```IConnectionProvider```
- ```IQueryMiddleware```
- ```IStorageConnectionProvider```
- ```IStorageOperationProvider```
- ```IStorageReaderProvider```
- ```IStorageWriterProvider```

By implementing all of the mentioned [Middleware](../Middleware.md) components you have your very own *Connected* [Storage Provider](StorageProviders.md).

## Virtual Storage

Not all [Entities](../Entities/README.md) require a physical storage. Some of them are virtual and are created by the service which manages them on startup and then the are destroyed on process shutdown.

[Cache](../Caching/README.md) is another storage that is virtual although it usually contains [Entities](../Entities/README.md) that are eventually storage physically.

## LINQ

The common feature for all storage types is the ability to manipulate with data with the help of LINQ. This also includes [Cache](../Caching/README.md) which also has a full support for LINQ. This way, there is no need to write a storage specific logic. Namely, *Microsoft SQL Server* supports *T-SQL* procedural language but *Oracle* supports *PL/SQL*. Those two are not completely compatible and by writing a database specific code we lose the flexibility.

For example, if we want to query all records from the entity ```IProject```, we would write code like this:

```csharp
return await Storage.Open<Project>().AsEntities<IProject>();
```

That's all you need to do. No procedures, select statements and ORM mappings.

If, for example, we would want to select a particular ```IProject```, the code would look like this:

```csharp
return await Storage.Open<Project>().Where(f => f.Id == Dto.Id).AsEntity();
```