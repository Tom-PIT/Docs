# Service Operations

[Services](README.md) consists of one or more methods which are called operations. Operation are not typical methods found in ```classes```, they behave very differently. A typical Operation call has a complex, but well designed pipeline which executes in stages.

> It is not necessary to use the *Connected* service pipeline but it is highly recommended since it encapsulates all the complexity needed to property execute a single operation.

## Model
Service operation in its model is just a method signature. An operation typically returns a ```Task``` which later enables ```async``` implementation if needed. In fact, virtually entire [Core](../../Environment/Core.md) Services are asynchronous. The following code shows an operation model:

```csharp
[Service, ServiceUrl("services/common-types/materials")]
public interface IMaterialService
{
    Task Update(UpdateMaterialDto dto);
}
```

Operations, similar to Services, can be accessible to external clients. By default, they are regarded as non visible. You don't need to decorate an operation with a ```ServiceUrlAttribute``` attribute, but use ```ServiceOperationAttribute``` instead. ```ServiceOperationAttribute``` accepts ```ServiceOperationVerbs``` flags ```enum``` which defines what ```Http``` verbs are allowed on the Operation. For example:

```csharp
[Service, ServiceUrl("services/common-types/materials")]
public interface IMaterialService
{
    [ServiceOperation(ServiceOperationVerbs.Post)]
    Task Update(UpdateMaterialDto dto);
}
```

The ```Update``` method from the preceding code is a perfect example of a Service Operation model which is exposed as an external service.

The Operation visibility is always controlled by a model. The reason behind is this behavior should not depend on implementation because changing the implementation [Microservice](../../Microservices/README.md) could break existing code.

This means ```ServiceOperation``` attribute has effect only on the interfaces not the implementations.

## Dto
Service Operations typically accepts [Dto](Dto.md) objects as arguments. There are several reasons for that. First, [Validation](Validation.md) is easier to manage as opposed to the primitive argument types. Second, adding properties to [Dto](Dto.md) does not break code. Third, [Dto](Dto.md) transitions are easier because we only need to pass a single object instead of a set of values. Next, [Dto](Dto.md) is extendable and we can control the validation with some advanced concepts which wouldn't be possible with primitive types. But the most important difference is that many [Middleware](Middlewares.md) components rely on [Dto](Dto.md) definitions. 
For example:
```csharp
public class InsertMaterialDto : Dto
{
    [Required, MaxLength(128)]
    string Name { get; set; }

    [Required, MaxLength(32)]
    string Code { get; set; }

    [NonDefault]
    DateTimeOffset Created { get; set; }

    Status Status { get; set; }
}
```
is a [Dto](Dto.md) object. If we have an Operation:
```csharp
Task<int> Insert(InsertMaterialDto dto);
```
then we can write [Validation](Validation.md) [Middleware](Middlewares.md):
```csharp
internal sealed class InsertMaterialValidator : Validator<InsertMaterialDto>
{
    protected override async Task OnInvoke()
    {
        // Validate the Dto
    }
}
```
If, on the other hand, out Service Operation would be:
```csharp
Task<int> Insert(string name, string code, DateTime created, Status status);
```
it would be impossible to implement middleware that could [Validate](Validation.md) the primitive arguments since there is nothing to attach to.

Service Operation typically accepts only one argument, which is of type ```IDto```. This is necessary since many components have constraints on ```IDto``` for various reasons so it's a good practice to follow this guideline.

## Return values
Service Operations can return values. Return values are mostly [Entities](../Entities/README.md). Service Operations can return a single [Entity](../Entities/README.md) or an array of [Entities](../Entities/README.md).

There are of course many Service Operations where the return value is just a Task. Those Service Operations are in fact ```void``` routines.

If a Service Operation returns a single [Entity](../Entities/README.md), the return value should be ```nullable```. For example:
```csharp
Task<IMaterial?> Select(PrimaryKeyDto<int> dto);
```
The preceding code shows that Service Operation might return a ```null``` value, if the requested record is not found.

For arrays, there are two rules:
- return value should always be ```ImmutableList<T>```
- it should always return value, never a ```null```

Immutability is necessary in multi user environments, because if one client requests a data, the other might already changing it when the first is trying to read it. ```Immutable``` collections solve this challenge and prevents writes to break enumerated lists. 

If an array is returned by a Service Operation and no items are available, an empty array should be returned instead of null. This is because there is no contextual difference between an empty list and null, they are both saying there are no records available. But clients would profit in that way that they don't need to check for nullability when calling Service Operations thus making code more readable.
For example:
```csharp
Task<ImmutableList<IMaterial>> Query();
```

## Implementation

Service Operations are typically implemented in separate source files. Each file contains one Service Operation and the operations are stored in a folder **Ops**.

Service operations are always internal and they are never instantiated directly, they always come from [Dependency Injection](../DependencyInjection/README.md) container.
The following code shows how the Service Operation should be invoked from the [Service](README.md):
```csharp
public async Task<int> Insert(InsertMaterialDto dto)
{
    return await Invoke(GetOperation<Insert>(), dto);
}
```
The preceding code demonstrates the interesting feature of the ```TomPIT.Services.Service``` base class. It performs an ```Invoke``` on a Service Operation retrieved from the inline ```GetOperation```, which is a generic method which accepts Service Operation type. The ```GetOperation``` simply retrieves the Service Operation ```Service``` from [Dependency Injection](../DependencyInjection/README.md) container. Service Operations are ```Transient ``` which means every request in the [Dependency Injection](../DependencyInjection/README.md) container creates a new instance.

## Operation types
*Connected* offers two types of Service Operations:

- ServiceAction<TDto>
- ServiceFunction<TDto, TReturnValue>

Service Actions are effectively ```void``` methods whereas Service Functions return values.

Both types accepts a [Dto](Dto.md) argument which is never null, even for Operations that do not require a [Dto](Dto.md). For example:
```csharp
internal sealed class Query : ServiceFunction<IDto, ImmutableList<IMaterial>>
{

}
```
By accepting ```IDto``` interface we told the *Connected* that any [Dto](Dto.md) can be passed into Service Operation, but it will be effectively ignored regardless of its type. calling this Service Operations would look like:
```csharp
public async Task<ImmutableList<IMaterial>> Query()
{
    return await Invoke(GetOperation<Query>(), Dto.Empty);
}
```

## Invocation Pipeline

Service Operation invocation is a complex process which is called a pipeline. Pipeline consists of a several stages each of which can be controlled by an external [Middleware](Middlewares.md) components. When a [Service](README.md) performs ```Invoke``` as the preceding code shows the following pipeline is constructed:
- Service Operation is registered in the [ITransactionContext](../Data/Transactions.md)
- an ```ICallerContext``` object is created which represents a Service Operation identity 
- a [Dto Values Providers](DtoValuesProviders.md) stage is executed
- an [Ambient Providers](AmbientProviders.md) stage is executed
- a [Calibration](Calibrators.md) stage is executed
- a [Validation](Validation.md) stage is executed
- a [Service Operation Authorization](#invoke-authorization) stage is executed
- an ```Invoke``` is called
- a [Service Operation Middlewares](#operation-middlewares) are executed
- in case of Service Function the [Service Operation Result Authorization](#result-authorization) stage is executed

As you can see, a lot is happening behind the ```Invoke``` call from the [Service](README.md) so it's a definitely a good idea to inherit all [Service](README.md) implementations from a ```TomPIT.Services.Service``` class.
The following code shows an example of the Service Action implementation:
```csharp
internal sealed class Update : ServiceAction<UpdateMaterialDto>
{
    
}
```

## Invoke Authorization

## Result Authorization

## Operation Middlewares

## Stages

### Commit

### Rollback

## Set State