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
There are several types of cache each serving for different purpose. Basically there are two types of cache:

- stateless
- stateful

