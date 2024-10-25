# Immutability

*Connected* is a shared, multi user environment which means different users or clients compete for the same resources. Most common resource is an ```Entity```, which represents a data structure, which holds a data.
Data is changed frequently, event in the same ```Entity``` instance. Many entities are [Cached](../Caching/README.md) and since entities are complex data structures consisting of many properties, performing changes is not Atomic process.

## The problem

When two clients access the same ```Entity``` one would like to modify it and the other one would like use its values for a calculation on another data set. When first client starts to modify the ```Entity```, the ```Entity``` becomes unstable because client modifies value by value. Unstable entities would mean unstable system and unstable system is not a system which is acceptable in a modern environments.

This is why *Connected* is designed entities are immutable. Immutable means their values cannot change once the ```Entity``` has been initialized and thus there is no risk for unstable systems.

## Modifications

If we need to perform a modification on an entity, we retrieve entity, create a new instance, modify values on the newly created instance and the we post changes to the either [Cache](../Caching/README.md) or database.

There is the possibility that another client already posted changes to the same ```Entity``` in the meantime, but for those scenarios *Connected* provides two different techniques:
- [Consistency](Consistency.md)
- [Concurrency](Concurrency.md)

## Example
Let's se an example how to make modifications to the entity. First, the model:
```csharp
public interface IStock : IEntity<int>
{
    int Location { get; init; }
    float Value { get; init; }
}
```
Now, let's implement it:
```csharp
internal record Stock : Entity<int>, IStock
{
    public int Location { get; init; }
    public float Value { get; init; }
}
```
Let's instantiate the entity:
```csharp
var entity = new Stock
{
    Location = 1,
    Value = 10
}; 
```
Now, if we want to modify the value of the instantiated entity we would do it in the following manner:
```csharp
var modified = entity with
{
    Value = 2
};
```
```with``` keyword creates a copy of an existing entity and with a complex initializer we can easily inject new values.