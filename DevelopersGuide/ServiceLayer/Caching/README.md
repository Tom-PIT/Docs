# Caching

Most data is stored in a some kind of physical storage, commonly in a database or a file system. Communicating with a physical storage requires inter-process communication which brings latency and consumes system resources which is an expensive thing to do.

Databases offer fast data access so there is no fear that each query will take significant amount of time. But, there are scenarios where access to the physical storage is simply not fast enough.

For data that is frequently accesses and rarely modified it's better solution to keep it closer to the execution pipeline, which is in the memory of the process. This kind of storage is called **Cache**.

A Cache is preloaded set of data which is accessible directly from the RAM in the same process where is needed and it means very fast access to the data. This is true for a normal number of records. Namely, databases are really very optimized and searching through a few 10,000 of records if probably faster if you do it via database rather that with LINQ in memory since databases have indexes which helps them to optimize the queries. But for records below a few 1,000 a Cache is a perfect choice.

*Connected* offers a powerful caching services which helps you to deliver a high performance solutions.

Cache is a container of entities which are organized by their keys and are represented as a set of entries. 

## Expiration
Entries can be permanent or they can expire after a certain period of time. An expiration time can be absolute or sliding. Absolute expiration means the entry will be disposed after a fixed amount of time whereas the sliding expiration means that every time the entry has been touched its expiration moves forward and extends its lifetime.

## Cache Types
There are several types of caches each serving different purpose. Basically there are two types of caches:

- stateless
- stateful

Stateless cache is non reactive cache which means loading and refreshing entries must be done manually. A stateful cache tries to be as close to the actual entity in storage as possible means that changes in the storage refreshes the entry in the cache.

Stateful cache provides another special type of cache named **Entity Cache**.

## Architecture

*Connected* offers `ICachingService` which provides access to the shared cache where all cache entries are stored. Entries are stored in a containers which represents an intermediate layer between the cache and its entries. A container is identified by its `key`. Inside the container, a list of entries resides. Entries are identified by their `id` which is unique inside the container. This means that in order to retrieve an entry we need to know in which container is stored and its id.

However, accessing the entries directly is not recommended. There are several reasons for that:

- cache typically stores entities and entities are internal implementations of each [Service](../Services/README.md)
- [Entities](../Entities/README.md) are immutable and we cannot change them anyway and put them modified back to the container
- we don't know the lifetime of entries and changing it could cause inconsistent behavior
- we can't control initialization and invalidation since we do not manage the entity
- `IConcurrentEntity` is implementation of the entity not model and we don't have information how the entity was implemented but using the mentioned interface is essential for achieving in process consistency

Instead of accessing entries directly we implement a `ICacheClient` which manages the specific container. For more information on the different implementations, use the links in **Next Steps**.

## Context Cache

Caching is a complex area to cover because it represents 

## Concurrency

---
**Next Steps**
- Stateless Cache
- Stateful Cache
- Entity Cache
