# Dto

Dto stands for *Data Transformation Object* and Dtos play an important role in the *Connected* platform.

Dto objects have two simple tasks:

- to move data between [Service Operation](Operations.md) calls
- to accept data from clients an pass it to the [Service Layer](README.md)

Dto objects have no business logic. They consist of one or more properties which together define a data structure needed to invoke a [Service Operation](Operations.md).

For example:

```csharp
public class InsertMeasureUnitDto : Dto
{
    [Required, MaxLength(128)]
    public string Name { get; set; }
    ...
}
```
The preceding example shows a typical Dto object.

## Model

Dto objects are always defined in a [Model](../../Microservices/Model.md) [Microservice](../../Microservices/README.md). It means they, along with [Entities](../Entities/README.md) and [Services](README.md), form a model which is later implemented in the implementation [Microservices](../../Microservices/README.md).

Dtos are always public and all of their properties are writable. The reason behind that is Dto object can change while in the [Execution Pipeline](Operations.md#invocation-pipeline).

## Attributes

Dtos main feature are attributes with whom properties are decorated. There are two main types of attributes that are used in Dtos:

- [Validation](Validation.md)
- ```Meta```

[Validation](Validation.md) attributes are used in the [Service Layer](../../ServiceLayer/README.md) and [User Layer](../../UserLayer/README.md) whereas ```Meta``` attributes are used only in [User Layer](../../UserLayer/README.md).

### Validation

*Connected* guarantees that a Dto object is [Validated](Validation.md) before it enters the [Invoke](Operations.md#stages) stage of the [Service Operation](Operations.md) which means all attributes set on properties must pass the rules.

On the [User Layer](../../UserLayer/README.md) the [Validation](Validation.md) rules also come from the same origin - the Dto. 

- Learn more about [Dto Binding](../../UserLayer/Data/DtoBinding.md)

### Meta

Meta attributes serves for the display purposes, such as ```Display``` attribute. For Example:
```csharp
public class InsertMaterialDto : Dto
{
	[Required, MaxLength(128)]
	[Display(ResourceType = typeof(ServiceOperationStrings), Name = nameof(ServiceOperationStrings.MaterialName))]
	public string Name { get; set; } = default!;

    ...
}
```
The preceding code shows how to use a display attribute which is later used in [User Layer](../../UserLayer/README.md). By using the *Connected* [Resource Strings](../../Globalization/ResourceStrings.md) you can easily enable multilingual user experience.

- Learn more about [Dto Binding](../../UserLayer/Data/DtoBinding.md)

## Middlewares

Most [Middleware](Middlewares.md) components are actually attached to the Dto definition, for example:
``` csharp
internal sealed class InsertMaterialValidator : Validator<InsertMaterialDto>
{
	protected override async Task OnInvoke()
	{
		// Perform validation

		await Task.CompletedTask;
	}
}
```
The preceding code shows that a validator is primarily attached to Dto object not the Service Operation to which it is passed. That's because the [Validation](Validation.md) is performed before the [Service Operation](Operations.md) invokes.

Another example is with [Authorization](Authorization.md):
```csharp
[Middleware<IMaterialService>(nameof(IMaterialService.Insert))]
internal sealed class InsertMaterialAuthorization : ServiceOperationAuthorization<InsertMaterialDto>
{

}
```

## User Layer

Dtos are widely used in [User Layer](../../UserLayer/README.md) as well. Every [Proxy](../../UserLayer/Services/Proxies.md) call is made with the help of Dto but since the ```javascript``` is not a type safe language, Dtos are not strongly typed. For example:

```javascript
async insert(name, code, status){
    return await this._post('insert', {
        name,
        code,
        status
    });
}
```

The preceding code shows a typical [Proxy](../../UserLayer/Services/Proxies.md) call from the *Web browser* to the [Service Layer](../../ServiceLayer/README.md).