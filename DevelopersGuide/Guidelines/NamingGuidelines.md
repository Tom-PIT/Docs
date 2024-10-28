# Naming Guidelines

## Microservices

### Models
Always append **.Model** [Models](../Microservices/Model.md) to the name of the [Microservice](../Microservices/README.md) so when referencing the user can quickly separate [Models](../Microservices/Model.md) from other type of [Microservices](../Microservices/README.md). For example:

```
TomPIT.Core.Model
```

## Namespaces
Don't use ```Model``` or ```Core``` in the ```namespaces``` event if the [Microservice](../Microservices/README.md) name contains it. For example, if we have a [Microservice](../Microservices/README.md) with a name **TomPIT.Common.Types.Model** we would model its ```IMeasureUnit``` [Entity](../ServiceLayer/Entities/README.md) as follows:
```csharp
namespace TomPIT.Common.Types.MeasureUnits;
```