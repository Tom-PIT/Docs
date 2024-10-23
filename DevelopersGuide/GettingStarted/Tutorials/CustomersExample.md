# Tutorial: Get Started with Tom PIT.connected

This tutorial shows how to create a fully featured service with a simple user interface for managing a single *Entity*.

You will learn how to:
- model microservice
- implement [Service Layer](../../ServiceLayer/README.md)
- implement [User Layer](../../UserLayer/README.md)

At the end of this tutorial, you'll have a working ```Customer``` entity with *CRUD* operations on the user interface.

> Microservice for this tutorial is available in the [Tutorials Repository](https://connected.tompit.com/repositories?folder=Repositories%252FTom%2520PIT&document=813&type=Repository).

## Scenario

We want to create a user interface for managing a ```Customer``` entity. ```Customers``` need to be stored in the database and all operations must be accessible via ```REST``` services.

> *Connected* [guidelines](../../Guidelines/Microservices.md) recommend loosely coupled architecture, but for the sake of simplicity we are going to write all source code in a single microservice.

## Microservice

First, [create](../../IDE/CreateMicroservice.md) a new microservice named **Tutorials.CustomersExample**.
Since we are going to write code in a single microservice let's create folders for each virtual microservice:
- **Model**
- **Customers**
- **JS**
- **Views**

### References

Microservice already contains a reference to the ```TomPIT.Core.Model``` microservice. We need to [add](../../IDE/AddReference.md) two additional references since we are going to implement all features in the same microservice:
- ```TomPIT.Core.Web.Lib```
- ```TomPIT.Core.Web.Components```

## Model

First, we are going to create model components. Model consists of the following components:
- one [Entity](../../ServiceLayer/Entities/README.md), which represents a data structure
- a few [Dtos](../../ServiceLayer/Services/Dto.md), which are needed for passing data into service operations
- one [Service](../../ServiceLayer/README.md), for manipulating the entity

### Create ```Entity```

We'll model an [Entity](../../ServiceLayer/Entities/README.md) which will represent a ```Customer```.
Add a new ```Code``` component in the **Model** folder named ```ICustomer```.
Paste the text below into the source file.
```csharp
namespace Tutorials.CustomersExample;

public interface ICustomer : IEntity<int>
{
	string Name { get; init; }
}
```
```ICustomer``` has two properties, an ```Id``` and a ```Name```.

Next, before we model a [Service](../../ServiceLayer/README.md), we are going to model [Dtos](../../ServiceLayer/Services/Dto.md) because they are needed by service operations.

Create a new subfolder in the **Model** folder named **Dtos**.

### Create ```InsertCustomerDto```
Under the **Dtos** folder, add a new ```Code``` component named ```InsertCustomerDto```.
Paste the text below into the source file.
```csharp
using System.ComponentModel.DataAnnotations;

namespace Tutorials.CustomersExample;

public class InsertCustomerDto : Dto
{
	[Required, MaxLength(128)]
	public string Name { get; set; } = default!;
}
```
This ```Dto``` accepts only one property called ```Name```. It's required which means client must pass the value which, in turn, should not exceed 128 characters. 

>  Attribute validation is done automatically by *Connected* and it is never required to validate ```Dto``` instance manually. 
### Create ```UpdateCustomerDto```
Under the **Dtos** folder, add a new ```Code``` component named ```UpdateCustomerDto```.
Paste the text below into the source file.
```csharp
using System.ComponentModel.DataAnnotations;

namespace Tutorials.CustomersExample;

public class UpdateCustomerDto : Dto
{
	[MinValue(1)]
	public int Id { get; set; }

	[Required, MaxLength(128)]
	public string Name { get; set; } = default!;
}
```
There is just a small difference between the first two ```Dtos```. ```UpdateCustomerDto``` accepts an ```Id``` which serves and an identifier to which customer should be updated.

### Create ```ICustomerService```

We have modeled all the necessary components. It's time to model a ```Service```. ```Service``` will provide the following operations for manipulating the ```Entity```:
- ```Insert```, for adding a new customer
- ```Update```, for modifying existing customer
- ```Delete```, for deleting an existing customer
- ```Query```, for querying customers
- ```Select```, for selecting a single customer

Under the **Model** folder, add a new ```Code``` Component named ```ICustomerService```. Paste the text below into the source file.
```csharp
namespace Tutorials.CustomersExample;

[Service, ServiceUrl("services/tutorials/customers-example")]
public interface ICustomerService
{
	[ServiceOperation(ServiceOperationVerbs.Put | ServiceOperationVerbs.Post)]
	Task<int> Insert(InsertCustomerDto dto);

	[ServiceOperation(ServiceOperationVerbs.Post)]
	Task Update(UpdateCustomerDto dto);

	[ServiceOperation(ServiceOperationVerbs.Delete | ServiceOperationVerbs.Post)]
	Task Delete(PrimaryKeyDto<int> dto);

	[ServiceOperation(ServiceOperationVerbs.Get | ServiceOperationVerbs.Post)]
	Task<ImmutableList<ICustomer>> Query();

	[ServiceOperation(ServiceOperationVerbs.Get | ServiceOperationVerbs.Post)]
	Task<ICustomer?> Select(PrimaryKeyDto<int> dto);
}
```
At this point, we have completed a model for a ```Customer``` microservice.
## Service Implementation
We have a model defined, now we need to implement it. In a real world scenario, an implementation can be very specific, from retrieving customers from a remote service, to being a completely virtual or a default one, to implement as a permanent storage.

We will move now to the **Customers** folder.

### ```Customer```
The first component to be implemented is ```Entity```. Add a new ```Code``` component in the **Customers** folder named **Customer**. Paste the text below into the source file.
```csharp
using TomPIT.Annotations.Entities;

namespace Tutorials.CustomersExample;

[Table(Schema = "tutorials")]
internal sealed record Customer : Entity<int>, ICustomer
{
	[Length(128)]
	public string Name { get; init; } = default!;
}
```
This is an implementation of the ```ICustomer``` entity. By putting the ```Table``` attribute we are instructing *Connected* to automatically create a database table for us. There is no need to take care of the database schemas even if we later change the entity structure.

Now we are going to implement service operations and once they are ready, the last thing to implement in the service scope is the service itself.

Create a new subfolder named **Ops** underneath **Customers**.

### ``Insert`` Operation
Add a new ```Code``` component in the **Ops** folder named **Insert**. Paste the text below into the source file.
```csharp
using TomPIT.Entities.Storage;

namespace Tutorials.CustomersExample;

internal sealed class Insert : ServiceFunction<InsertCustomerDto, int>
{
	public Insert(IStorageProvider storage)
	{
		Storage = storage;
	}

	private IStorageProvider Storage { get; }

	protected override async Task<int> OnInvoke()
	{
		var entity = await Storage.Open<Customer>().Update(Dto.AsEntity<Customer>(State.New));

		if (entity is null)
			throw new NullReferenceException();

		return entity.Id;
	}
}
```
This is the implementation of the ```Insert``` operation. As you can see it's very simple and intuitive. We simply request a storage from [Dependency Injection](../../ServiceLayer/DependencyInjection/README.md) container and then convert a ```Dto``` to ```Customer``` entity and by calling the ```Update``` on the storage the *Connected* performs a database execute. By setting the ```State``` to ```New``` we are instructing the *Connected* it's a new record which means it will perform an insert operation.
> *Connected* automatically returns a newly inserted identity value and attaches it to the entity's ```Id``` property.
### ```Update``` Operation
Add a new ```Code``` component in the **Ops** folder named **Update**. Paste the text below into the source file.
```csharp
using TomPIT.Entities.Storage;

namespace Tutorials.CustomersExample;

internal sealed class Update : ServiceAction<UpdateCustomerDto>
{
	public Update(IStorageProvider storage, ICustomerService customers)
	{
		Storage = storage;
		Customers = customers;
	}

	private IStorageProvider Storage { get; }
	private ICustomerService Customers { get; }

	protected override async Task OnInvoke()
	{
		var existing = await Customers.Select(Dto.Id) as Customer;

		if (existing is null)
			throw new NullReferenceException();

		await Storage.Open<Customer>().Update(existing.Merge(Dto, State.Default));
	}
}
```
This operation performs an update on a ```Customer``` entity. It is very similar to the ```Insert``` operation with the exception we first perform a ```Select``` to retrieve an existing ```Customer``` and then we merge a ```Dto``` object with entity.
### ```Delete``` Operation 
Add a new ```Code``` component in the **Ops** folder named **Delete**. Paste the text below into the source file.
```csharp
using TomPIT.Entities.Storage;

namespace Tutorials.CustomersExample;

internal sealed class Delete : ServiceAction<PrimaryKeyDto<int>>
{
	public Delete(IStorageProvider storage)
	{
		Storage = storage;
	}

	private IStorageProvider Storage { get; }

	protected override async Task OnInvoke()
	{
		await Storage.Open<Customer>().Update(Dto.AsEntity<Customer>(State.Deleted));
	}
}
```
This implementation is even simpler. We just take a ```Dto``` and perform a delete operation by instructing the *Connected* the entity's ```State``` is a ```Deleted```.
### ```Select``` Operation
Add a new ```Code``` component in the **Ops** folder named **Select**. Paste the text below into the source file.
```csharp
using TomPIT.Entities.Storage;

namespace Tutorials.CustomersExample;

internal sealed class Select : ServiceFunction<PrimaryKeyDto<int>, ICustomer?>
{
	public Select(IStorageProvider storage)
	{
		Storage = storage;
	}

	private IStorageProvider Storage { get; }

	protected override async Task<ICustomer?> OnInvoke()
	{
		return await Storage.Open<Customer>().Where(f => f.Id == Dto.Id).AsEntity();
	}
}
```
This operation reads a single ```Customer``` from the database based on the supplied ```Id```. As you can see there is no database scripts included, no need to deal with database specifics and no ORM mappings. We simply use LINQ to perform all query operations.
### ```Query``` Operation
Add a new ```Code``` component in the **Ops** folder named **Query**. Paste the text below into the source file.
```csharp
using TomPIT.Entities.Storage;

namespace Tutorials.CustomersExample;

internal sealed class Query : ServiceFunction<IDto, ImmutableList<ICustomer>>
{
	public Query(IStorageProvider storage)
	{
		Storage = storage;
	}

	private IStorageProvider Storage { get; }

	protected override async Task<ImmutableList<ICustomer>> OnInvoke()
	{
		return await Storage.Open<Customer>().AsEntities<ICustomer>();
	}
}
```
This is the simplest operation which returns all customers from the database. 
### ```CustomerService``` Service
Add a new ```Code``` component in the **Customers** folder named **CustomerService**. Paste the text below into the source file.
```csharp
namespace Tutorials.CustomersExample;

internal sealed class CustomerService : Service, ICustomerService
{
	public CustomerService(IContext context) : base(context)
	{

	}

	public Task<int> Insert(InsertCustomerDto dto)
	{
		return Invoke(GetOperation<Insert>(), dto);
	}

	public Task Update(UpdateCustomerDto dto)
	{
		return Invoke(GetOperation<Update>(), dto);
	}

	public Task Delete(PrimaryKeyDto<int> dto)
	{
		return Invoke(GetOperation<Delete>(), dto);
	}

	public Task<ImmutableList<ICustomer>> Query()
	{
		return Invoke(GetOperation<Query>(), Dto.Empty);
	}

	public Task<ICustomer?> Select(PrimaryKeyDto<int> dto)
	{
		return Invoke(GetOperation<Select>(), dto);
	}
}
```
This is the implementation of the ```ICustomerService``` service. As you can see, there is no specific logic inside the component, only invocation routines to the actual operations.

At this point, we have all components needed for the [Service Layer](../../ServiceLayer/README.md). This service is fully REST supported and you could for example access it through a *Postman* application or [Quality](../../Environment/Quality.md) instance.

Now the service layer is modeled and implemented we can start implement client side.

## User Layer

User layer consists of ```javascript``` code and ```html``` templates, which, combined together, form reusable web components. ```javascript``` files are most commonly implemented as modules.

### ```Proxy``` module
The first component is the ```Proxy``` which acts as a bridge between [Service Layer](../../ServiceLayer/README.md) and a [User Layer](../../UserLayer/README.md).

We are going to use **JS** folder from now on.

Under the **JS** folder create a new folder named **Proxies**.
Create a new ```File``` component in the **Proxies** folder and name it **CustomerProxy.mjs**. Paste the text below into the source file
```javascript
import { ServiceClient } from '@lib';

export class CustomerProxy extends ServiceClient {
   constructor() {
      super('services/tutorials/customers-example');
   }

   async insert(name) {
      return await this._post('insert', {
         name
      });
   }

   async update(id, name) {
      return await this._post('update', {
         id,
         name
      });
   }

   async delete(id) {
      return await this._post('delete', {
         id
      });
   }

   async select(id) {
      return await this._post('select', {
         id
      });
   }

   async query() {
      return await this._post('query');
   }

   async bind(model, operation, id = undefined) {
      let entity = {};

      if (!id)
         entity = { name: null };
      else
         entity = await this.select(id);

      await model.bindDto(await super._selectDto(operation), entity);
   }
}
```
As you can see there is not much difference between server and client, operations simply delegate calls to the server. There is one notable difference though, the ```bind``` operation which serves as an [automatic binder](../../UserLayer/Data/DtoBinding.md) of the ```Dto``` object into the [Model](../../UserLayer/Data/Model.md).

We must also enable this service to the clients by setting its' ```Url``` property in the [Property Grid](../../IDE/PropertyGrid.md). Enter the value **services/tutorials/customers-example**.

### Components

It's time to create UI components. The entire *Connected* [UI Framework](../../UserLayer/UIFramework.md) is implemented with the help of *WebComponents* technique which means it's organized into a set of reusable components that can be used independently of each other and on any user interfaces.

We'll place all components inside the **Customers** underneath the **JS** folder so you need to create this folder first.

### Form web component
This first UI component is the edit form which will serve as the editor for either a new ```Customer``` or the existing one. We need two files for this, a ```template``` and a ```javascript``` file. Create a new ```File``` component named **Form.html** and paste the text below into a source file.
```html
<template name="form">
   <tp-form>
      <tp-form-body>
         <div>
            <div>
               <tp-label for="name"></tp-label>
               <tp-text-box name="name" focus></tp-text-box>
            </div>
         </div>
      </tp-form-body>
      <tp-form-footer>
         <div class="mt-3 d-flex justify-space-between">
            <tp-button kind="save" class="btn btn-primary">
               Save
            </tp-button>
            <div>
               <tp-button kind="delete" class="btn btn-danger">
                  Delete
               </tp-button>
               <tp-button kind="cancel" class="btn btn">
                  Cancel
               </tp-button>
            </div>
         </div>
      </tp-form-footer>
   </tp-form>
</template>
```
It's a simple ```html``` markup with one input field for the name property and three buttons. You have probably noticed how clean the markup is, with no validation or other unnecessary markup. The *Connected* will put all pieces together automatically for you.
Now add the ```File``` component named **Form.mjs** and paste the text below into a source file.
```javascript
import { DataBoundComponent } from '@lib/components';

class Form extends DataBoundComponent {
   #form;
   #saveButton;
   #cancelButton;
   #deleteButton;

   async _onConnected() {
      this.#form = await this._renderTemplate(this, null, 'templates/tutorials/customers-example', 'form');
      this.#saveButton = this.#form.querySelector('tp-button[kind="save"]');
      this.#cancelButton = this.#form.querySelector('tp-button[kind="cancel"]');
      this.#deleteButton = this.#form.querySelector('tp-button[kind="delete"]');

      this.#saveButton.addEventListener('buttonClick', this.#saveClick);
      this.#cancelButton.addEventListener('buttonClick', this.#cancelClick);
      this.#deleteButton.addEventListener('buttonClick', this.#deleteClick);

      this.model.addEventListener('valueChanged', this.#modelValueChanged);

      this.#modelValueChanged();
      
      await super._onConnected();
   }

   #saveClick = async (e) => {
      if (!(await this.model.validate()))
         return;

      this._dispatchEvent('saveClick', { sender: this });
   }

   #cancelClick = () => {
      this._dispatchEvent('cancelClick', { sender: this });
   }

   #deleteClick = () => {
      this._dispatchEvent('deleteClick', { sender: this });
   }

   #modelValueChanged = () => {
      if (this.model.data.id)
         this.#deleteButton.show();
      else
         this.#deleteButton.hide();
   }
}

customElements.define('customer-form', Form);
```
Again, it's very simple. We load the template and this component is only responding to button clicks and triggers events to which components' clients are listening.

Enable this component to the clients by setting it's ```Url``` property to the **components/tutorials/customers-example/form** in the [Property Grid](../../IDE/PropertyGrid.md).

### List web component
List component will serve as a display for existing customers. Add a new ```File``` component named **List.html** and paste the text below into a source file.
```html
<template name="list">
   <tp-table id="customers" data-source="customers" key-property="id">
      <tp-table-columns>
         <tp-table-column data-member="name">
            <tp-table-column-content>
               <a href="#" kind="customer" data-id="{{id}}">{{name}}</a>
            </tp-table-column-content>
         </tp-table-column>
      </tp-table-columns>
   </tp-table>
</template>
```
The list component basically wraps the *Connected* table web component and displays one column which is bound to the ```name``` property. Let's create it's implementation by adding a new ```File``` component named **List.mjs**. Paste the text below into a source file.
```javascript
import { Model } from '@lib';
import { DataBoundComponent } from '@lib/components';

class List extends DataBoundComponent {

   constructor() {
      super();
      this.model = new Model();
   }

   async _onConnected() {
      await super._renderTemplate(this, null, 'templates/tutorials/customers-example', 'list');

      this.selectComponent('tp-table').addEventListener('selectionChanged', this.#rowClick);
      this.selectComponent('#customers').addEventListener('cellRendering', this.#cellRendering.bind(this));

      await super._onConnected();
   }

   get customers() {
      return this.model.dataSources.customers;
   }

   set customers(value) {
      this.model.dataSources.customers = value;
   }

   #cellRendering(e) {
      const link = e.detail.element.selectComponent('a[kind="customer"]');

      if (link) {
         link.removeEventListener('click', this.#editClick);
         link.addEventListener('click', this.#editClick);
      }
   }

   #editClick = async (e) => {
      e.preventDefault();
      this._dispatchEvent('editClick', { id: e.currentTarget.dataset.id });
   }

   #rowClick = async (e) => {
      this._dispatchEvent('rowClick', {
         sender: this,
         record: e.detail.selectedItems[0]
      });
   }
}

customElements.define('customer-list', List);
```
This component simply awaits the data source to be attached and than displays the list of existing customers.

Enable this component to the clients by setting it's ```Url``` property to the **components/tutorials/customers-example/list** in the [Property Grid](../../IDE/PropertyGrid.md).

### Container component

The last component we are going to create is a ```Container```. It a composite component which contains both, a ```Form``` and a ```List``` and manages the communication between them.
Add a new ```File``` component named **Container.html** and paste the text below into a source file.
```html
<template name="container">
   <tp-container mode="single">
      <tp-section name="list" class="tp-active">
      </tp-section>
      <tp-section name="form">
      </tp-section>

      <tp-button on-click="add" role="add" name="add" class="btn btn-primary mt-3">
         Add
      </tp-button>
   </tp-container>
</template>
```
```Container``` contains two sections, one for the ```List``` and the other for ```Form```. It will switch between them accordingly.
Now add another ```File``` component named **Container.mjs** and paste the the below into a source file.
```javascript
import { DataBoundComponent } from '@lib/components';
import { CustomerProxy } from '@services/tutorials/customers-example';
import '@components/tutorials/customers-example/form';
import '@components/tutorials/customers-example/list';

class Container extends DataBoundComponent {
   #container;
   #list;
   #form;
   #customers = new CustomerProxy();
   #buttonAdd;

   async _onConnected() {
      this.#container = await super._renderTemplate(this, undefined, 'templates/tutorials/customers-example', 'container');

      this.#buttonAdd = this.#container.querySelector('tp-button[role="add"]');
      this.#buttonAdd.addEventListener('buttonClick', this.#add);

      await this.#renderList();
      await this.#renderForm();
   }

   async #renderList() {
      const listSection = this.#container.selectSection('list');

      this.#list = super._renderComponent(listSection, 'customer-list');
      this.#list.addEventListener('rowClick', this.#rowClick);
      this.#list.addEventListener('editClick', this.#edit);
      this.#list.customers = await this.#customers.query();
      this.#container.showSection('list');
   }

   async #renderForm() {
      const section = this.#container.selectSection('form');

      this.#form = super._renderComponent(section, 'customer-form');

      this.#form.addEventListener('saveClick', this.#save);
      this.#form.addEventListener('cancelClick', this.#cancel);
      this.#form.addEventListener('deleteClick', this.#delete);
   }

   #rowClick = async (e) => {
      var id = e.detail.record.id;

      await this.#customers.bind(this.model, 'update', id);

      this.#container.showSection('form');
   }

   #edit = async (e) => {
      await this.#customers.bind(this.model, 'update', e.detail.id);

      this.#container.showSection('form');

      this.#buttonAdd.classList.add('d-none');
   }

   #save = async () => {
      if (!this.model.validate())
         return;

      const record = this.model.data;

      if (record.id)
         await this.#customers.update(record.id, record.name, record.code, record.precision, record.status);
      else
         await this.#customers.insert(record.name, record.code, record.precision, record.status);

      await this.#container.showSection('list');

      this.#buttonAdd.classList.remove('d-none');
   }

   #cancel = async () => {
      await this.#container.showSection('list');

      this.#buttonAdd.classList.remove('d-none');
   }

   #delete = async () => {
      await this.#customers.delete(this.model.data.id);
      await this.#container.showSection('list');

      this.#buttonAdd.classList.remove('d-none');
   }

   #add = async () => {
      await this.#customers.bind(this.model, 'insert');

      this.#container.showSection('form');

      this.#buttonAdd.classList.add('d-none');
   }
}

customElements.define('customer-container', Container);
```
Set its ```Url``` property to **components/tutorials/customers-example/container**.

At this point, we have all components implemented and ready to use.

### Bundling

We are going to perform another task which is not strictly necessary but is recommended in the *Connected* [guidelines](../../Guidelines/README.md). One of the optimization routines is called *bundling* where we put together similar template files which serves as a single unit. The easiest way to do it is to put all templates in the same folder and then add a new ```json``` ```File``` component. Let's add a new component under the **JS/Customers** folder and name it **Customers.json**. Paste the text below into a file.
```json
{
   "files": [
      "/*"
   ]
}
```
Set its ```Url``` property to **templates/tutorials/customers-example**.

### ```View``` Component

The very last component we will add is the ```View```. ```View ``` provides two notable features:
- ```Url``` under which it is accessible
- initializes *Connected* client environment so the [UI Framework](../../UserLayer/UIFramework.md) becomes functional

Let's add a ```File``` component named **Customers.cshtml** under the **Views** folder. Paste the text below into a source file.
```cshtml
@using TomPIT.Web.Razor;

@{
   Layout = "/TomPIT.Core.Web.Components/MasterViews/Default.cshtml";
}

<tp-view>
   <customer-container></customer-container>
</tp-view>

<script type="module">
    import '@Html.TomPIT().JavaScript.BundlePath("components/tutorials/customers-example/container")';
    import { Customers } from '@Html.TomPIT().JavaScript.BundlePath("views/tutorials/customers-example")';

    await new Customers().initialize();
</script>
```
This is a markup file with a small amount of script code just to bootstrap the [UI Framework](../../UserLayer/UIFramework.md).

Set the ```Url``` property to **customers-example/customers**. This is the actual url under which the view will be accessible.

Now add another ```File``` component named **Customers.mjs** and paste the text below into a source file.
```javascript
import { View } from '@lib';

export class Customers extends View {
}
```
This is just a small wrapper which is called from the view to properly set up the [UI Framework](../../UserLayer/UIFramework.md).

Congratulations! You have a fully working user interface with the entire set of features for adding, updating, deleting and displaying a ```Customer``` entity.

If you now click on the **Restart QA** button on the [IDE](../../IDE/README.md) toolbar the view will become accessible from the browser. Navigate to the [YourHost]/customers-example/customers and you will see a screen with an **Add** button on it.

### Test the Results
Let's do some tests to verify our microservice is working as expected.
> Note that most of the features required in the real world scenarios are omitted to keep this tutorial as simple as possible.
1. Run browser and navigate to the address of the customers view
2. An empty screen is shown with an **Add** button
3. Click on a button and enter **Customer 1** into the *name* text input
4. Click on the **Save** button
5. Refresh the browser. A list displaying a ```Customer`` with name **Customer 1** is shown
6. Click on the hyperlink and change the value to **Customer v2**
7. Click on the **Save** button and refresh the browser again
8. An updated ```Customer``` is shown
9. Click on the customer's name again and click on the **Delete** button
10. Refresh the screen and no customers are displayed since we just deleted the only one

## Summary
You've just completed the very basic concept of the *Connected* platform. You are now ready to learn about more advanced concepts to be ready to complete real world tasks as soon as possible.