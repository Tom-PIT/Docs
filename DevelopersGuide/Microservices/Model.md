# Model

A Model [Microservice](README.md) is a special type of [Microservice](README.md) which offers the architecture of the digital content which is prescribed with [Artifacts](../ServiceLayer/Artifacts/README.md). It's always the first step in design where we model [Entities](../ServiceLayer/Entities/README.md) and [Services](../ServiceLayer/Services/README.md) and in this way we get a good idea how an end product will look like and how it will interact to other Microservices.

Architecture errors are found before the first implementation code is written and we can event start to design other Microservices before we implement the first one.

A Model is just a Model. It defines component definitions but not the implementation. Model is fixed and cannot change whereas implementation can change at any time. This is why the Model phase is so important.

A typical Model defines multi [Services](../ServiceLayer/Services/README.md) and their corresponding [Entities](../ServiceLayer/Entities/README.md) whereas an [implementation](../ServiceLayer/Services/README.md) implements only one [Service](../ServiceLayer/Services/README.md) in the [Microservice](../Microservices/README.md). For example, for the [Core](../Environment/Core.md) Microservices there is a **TomPIT.Common.Types.Model** [Microservice](README.md) which among others models the following [Services](../ServiceLayer/Services/README.md):

- IMeasureUnitService
- ICountryService
- ICurrencyService

Those [Services](../ServiceLayer/Services/README.md) are all modelled in the [Microservice](README.md) **TomPIT.Common.Types.Model** therefore in a single [Microservice](README.md). But their implementation is later performed in three Microservices, each of which implementing a single [Microservice](README.md). This way, we end up with the following [Microservice](README.md) set:

- TomPIT.Common.Types.MeasureUnits
- TomPIT.Common.Types.Countries
- TomPIT.Common.Types.Currencies

## Exceptions

There are some exceptions though. When we have a closely related [Entities](../ServiceLayer/Entities/README.md), for example *Document* and its *Items*, they are implemented in the same [Microservice](README.md) even two [Services](../ServiceLayer/Services/README.md) are modelled. For example:

- IInvoiceService
- IInvoiceItemService

would both be implemented in:

- Invoices

[Microservice](README.md).

## What to Model

The Model exists only for the [Service Layer](../ServiceLayer/README.md) not the [User Layer](../UserLayer/README.md). [User Layer](../UserLayer/README.md) is just REST client and is only guided by Model but it does not depend on it from the compiler's point of view. This means changes in the Model would not prevent a [JS](../UserLayer/UI/JSMicroservice.md) [Microservice](README.md) to run even if it would fail to work properly. So keep in mind to synchronize a Model changes with the [User Layer](../UserLayer/README.md).

## An Example

Let's assume we want to model a *Data Center* Management system. *Data Center* belongs to the *Region* where each *Region* can contain many *Data Centers*. [Create](../IDE/CreateMicroservice.md) named **Connected.Academy.DataCenters.Model**.

> A source code for this example is available in the [Connected.Academy.DataCenters.Model](https://connected.tompit.com/repositories?folder=Repositories%252FConnected%2520Academy&document=820&type=Repository) repository.

### Regions

First, we'll model *Regions*. Create folder named **Regions** and add a ```Code``` component named **IRegion** with the following code:

```csharp
namespace Connected.Academy.DataCenters.Regions;

public interface IRegion : IEntity<int>
{
	string Name { get; init; }
}
```
This is an [Entity](../ServiceLayer/Entities/README.md) which represents a *Region*. Next, create a new subfolder named **Dtos** and add a new ```Code``` component named **InsertRegionDto** with the following code:
```csharp
namespace Connected.Academy.DataCenters.Regions;

public class InsertRegionDto : Dto
{
	[Required, MaxLength(128)]
	public string Name { get; set; } = default!;
}
```

This is the [Dto](../ServiceLayer/Services/Dto.md) object for the ```Insert``` [Service Operation](../ServiceLayer/Services/Operations.md). The last component for the *Regions* is the [Service](../ServiceLayer/Services/README.md). Under **Regions** folder add a new ```Code``` component named **IRegionService** with the following code:
```csharp
namespace Connected.Academy.DataCenters.Regions;

[Service, ServiceUrl("services/models/regions")]
public interface IRegionService
{
	[ServiceOperation(ServiceOperationVerbs.Put)]
	Task<int> Insert(InsertRegionDto dto);
}
```

Considering that we have omitted some [Service Operations](../ServiceLayer/Services/Operations.md) to keep an example more simple we have just modelled a perfectly valid [Service](../ServiceLayer/Services/README.md).

### Data Centers

Now let's model a *Data Center*. Create a new folder named **DataCenters** and add a new ```Code``` component named **IDataCenter** with the following code:
```csharp
namespace Connected.Academy.DataCenters;

public interface IDataCenter : IEntity<int>
{
	int Region { get; init; }
	string Name { get; init; }
}
```
You can see the [Entity](../ServiceLayer/Entities/README.md) has a logical reference to the ```IRegion``` by its ```Id```. Next, create a new subfolder named **Ops** and add a new ```Code``` component named **InsertDataCenterDto** with the following code:
```csharp
namespace Connected.Academy.DataCenters;

public class InsertDataCenterDto : Dto
{
	[MinValue(1)]
	public int Region { get; set; }

	[Required, MaxLength(128)]
	public string Name { get; set; }
}
```
The only component remaining is the *Data Center* service. Under the **DataCenters** folder add a new ```Code``` component named **IDataCenterService** with the following code:
```csharp
namespace Connected.Academy.DataCenters;

[Service, ServiceUrl("services/models/data-centers")]
public interface IDataCenterService
{
	[ServiceOperation(ServiceOperationVerbs.Put)]
	Task<int> Insert(InsertDataCenterDto dto);
}
```

The resulting Model contains two [Services](../ServiceLayer/Services/README.md), an ```IRegionService``` and an ```IDataCenterService```. If we would now try to implement those [Services](../ServiceLayer/Services/README.md) we would create two [Microservices](README.md):

- Connected.Academy.DataCenters.DataCenters
- Connected.Academy.DataCenters.Regions
