# Concurrency

High performant systems have a need to cache commonly accessed data for performance reasons. Putting data in the memory dramatically improves the performance of the system. Unfortunately, it comes with a cost.

Having data in a cache means many users have an access to the same data at the same time, but with a very different idea what they would like to do with a data. Changes to the data in cache are immediately visible to other users, which means if we changed data only partially or we would like to undo our changes it could be already too late because other user(s) already accessed the same data and used it in some very critical calculations.

Such systems are unreliable and cannot guarantee that any calculation would result in the correct result. Think of bank systems, where one user could overwrite values from another, or, even worse, in a health systems, where parameters could damage the diagnose.

Caching data is great, but the platform should offer tools to address the challenges.

*Connected* supports a special ```Entity```, called ```IConcurrentEntity```. This entity works hand in hand with all *Connected* cache types. It contains a single property called ```Sync```. You don't have to deal with this value, you just have to implement this interface or a default ```ConcurrentEntity``` implementation and *Connected* will take care of the rest.

## How it works
When the ```Entity``` is first instantiated, its ```Sync``` value is automatically set to ```0```. Then the ```Entity``` is put in the [Cache](../Caching/README.md) and it becomes accessible to clients. Since all entities are [immutable](Immutable.md), we must retrieve the ```Entity``` from the [Cache](../Caching/README.md), modify it and then put it back in the [Cache](../Caching/README.md). This process is not Atomic and it's very likely that other client want to perform the very same action on exactly the same ```Entity``` but with a different modifications.
Once the modified value is returned in the [Cache](../Caching/README.md), the [Cache](../Caching/README.md) recognizes the ```Entity``` as a concurrent ```Entity``` and performs a look up in the list to find out if the ```Entity``` with the same key already exists. If so, it compares the ```Sync``` property and if they are not the same, the ```Exception``` is thrown. The ```Caller``` must handle the ```Exception``` and its very likely that it will repeat the process but it will retrieve a new, updated value from the [Cache](../Caching/README.md), before it will perform a calculation. An updated ```Entity``` will have a ```Sync``` value incremented which means the client will retrieve an ```Entity``` with changes from the other client already in place. 

This way, there is no risk the values would be overwritten by different clients.

## When to use it

You don't have to always implement ```Concurrent``` entity. There are specific scenarios when this kind of entity is needed. The most common scenarios is when an ```Entity``` have a property whose value depends on the context and can change very often. The other common property is that ```Concurrent``` entities are often virtual which means they are kept in memory but not persisted to the database. 

Let's see an example. We have a ```TextBuffer``` entity as follows:
```csharp
internal record TextBuffer : Entity<int>
{
    public int Document { get; init; }
    public byte[] Buffer { get; init; }
}
```
The ```TextBuffer``` entity is being instantiated and cached when first requested with the following values:
```csharp
var entity = new TextBuffer<int>
{
    Id = 1,
    Document = 15,
    Buffer: new byte[10] { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
};
```
Now, let's imagine we have a real-time text editor which enables clients to perform edits on documents simultaneously. If we have have five clients, each of them can enter up to 50 words per minute, which means 250 words per minute. We want to post a change for every character which means we end up with more that a 1,000 requests per minute for only five clients. Changes that two clients would like to change the same character are big.

Without concurrency technique clients would overwrite changes from one to another and such a system would make no sense.

Luckily, *Connected* resolves this challenge in an elegant manner. The only thing we need to change from the code above is to implement ```ConcurrentEntity``` instead of ```Entity```.

The model would like like the text below.
```csharp
internal record TextBuffer : ConcurrentEntity<int>
{
    public int Document { get; init; }
    public byte[] Buffer { get; init; }
}
```
This way, *Connected* would take care of the race conditions and will accept only the requests with correct cached versions.

In practice, when the [Cache](../Caching/README.md) rejects request, one or two more tries are very likely to be sufficient for a successful update. This logic is handled in the [Service](../Services/README.md) operation so the end user experience remains the same.