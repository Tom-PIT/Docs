# Tutorial: Get Started with Tom PIT.connected
This tutorial shows how to create a fully featured service with a simple user interface.

You will learn how to create:
- model microservice
- entity
- service
- client service
- UI components
- view

At the end, you'll have a working Customer entity with CRUD operations on the user interface.

## Scenario
We want to create an entity which represents a customer. We need a data structure for storing data, a service for manipulating data and client for interactive use of the data.

## Microservices
For this scenario we'll need to create 4 microservices:
- Tutorial.Customer.Model
- Tutorial.Customers
- Tutorial.Customers.JS
- Tutorial.Customers.Views

> Technically it's not necessary to create 4 microservices, we could put all source code in one microservice, but by following the *Connected* guideline, 4 microservices are recommended. This way, we'll have loosely coupled sistem where and microservices (except the model) can be replaced at any time.

## Creating a model microservice
First, we are going to create model. Model consists of an entity and a service. 
- in *Connected* IDE, navigate to the microservices, located at sys/development/local/microservices url under your host 
- click on the plus button at the bottom right corner
- the create microservice screen shows up. Click **Create from scratch** button
- enter **Tutorial.Customer.Model** in the *name* text box
- click **Create** button
- a *Connected* IDE shows up with a newly created workspace

We are now ready to start coding.

## Create Entity
We'll define an entity which will represent a ```Customer```.
Add a new *Code* component and name it ```ICustomer```.
Enter the following code in the source file:
```csharp
using TomPIT.Entities;

namespace Tutorial.Customer;

public interface ICustomer : IEntity<int>
{
	string Name { get; init; }
}
```
We have just defined a ```Customer``` entity, which has an ```Id``` property of the type ```int``` and a ```string``` property, which represents its name.

## Create ```ICustomerService```
Now that we have an *Entity* defined, we must create a model for its service. Service consists of operations where each operation typically accepts one argument which is called a ```Dto```. ```Dto``` stands for **Data transformation object** and its purpose is to move data from one endpoint to another. It never contains any business logic, only properties and their respective validation attributes.

```Customer``` service will contain the following methods:
- ```Insert```, for adding new customers
- ```Update```, for modifying existing customer
- ```Delete```, for deleting an existing customer
- ```Query```, for querying customers
- ```Select```, for selecting a single customer

*Connected* guideline expects ```Dto``` objects to be located in the *Dto* folder. Create a new folder named **Dto**.

Now we are ready to create ```Dto``` objects. Add a new *Code* component with a name **InsertCustomerDto** in the folder **Dto**. Paste the following code in the source file:
```csharp
using System.ComponentModel.DataAnnotations;
using TomPIT.Services;

namespace Tutorial.Customer;

public class InsertCustomerDto : Dto
{
	[Required, MaxLength(128)]
	public string Name { get; set; } = default!;
}
```

This ```Dto``` will be used when inserting a new ```Customer```. Note that we require the ```Name``` property to be specified with a ```Required``` attribute and we allow the value to be at most 128 characters long. Attribute validation is done automatically in *Connected*.

The second ```Dto``` is for updating an existing customer. Add another ```Code``` component and name it **UpdateCustomerDto** and paste the following code into it:
```csharp
using System.ComponentModel.DataAnnotations;
using TomPIT.Annotations;
using TomPIT.Services;

namespace Tutorial.Customer;

public class UpdateCustomerDto : Dto
{
	[MinValue(1)]
	public int Id { get; set; }

	[Required, MaxLength(128)]
	public string Name { get; set; } = default!;
}
```

```UpdateCustomerDto``` is very similar to the ```InsertCustomerDto``` with the exception it contains an id of the ```Customer```.

For the simple entities like ```Customer``` two ```Dto``` object are sufficient.

Now let's create an ```ICustomerService```.

Add *Code* Component with a name ```ICustomerService``` and paste the following code into it:
```csharp
using System.Collections.Immutable;
using TomPIT.Annotations;
using TomPIT.Services;
using System.Threading.Tasks;

namespace Tutorial.Customer;

[Service, ServiceUrl("services/customers")]
public interface ICustomerService
{
	[ServiceOperation(ServiceOperationVerbs.Put | ServiceOperationVerbs.Post)]
	Task<int> Insert(InsertCustomerDto dto);

	[ServiceOperation(ServiceOperationVerbs.Post)]
	Task Update(UpdateCustomerDto dto);

	[ServiceOperation(ServiceOperationVerbs.Delete | ServiceOperationVerbs.Post)]
	Task Delete(PrimaryKeyDto<int> dto);

	[ServiceOperation(ServiceOperationVerbs.Get | ServiceOperationVerbs.Post)]
	Task<ImmutableList<ICustomer>> Query(QueryDto? dto);

	[ServiceOperation(ServiceOperationVerbs.Get | ServiceOperationVerbs.Post)]
	Task<ICustomer?> Select(PrimaryKeyDto<int> dto);
}
```
At this point, we have complete a model for a *Customer* microservice. This way, any microservice requiring an ```ICustomer``` entity can reference this model without knowing what implementation will be available in the runtime.
## Customers microservice
We have a model defined, now we need to implement it. An implementation can be very specific, from retrieving a customer set from a remote service, to being a completely virtual or a default one, to implement a permanent storage.

Create a new microservice named **Tutorial.Customers**.
1. [Add Reference](https://github.com/Tom-PIT/Docs/blob/main/DevelopersGuide/IDE/AddReference.md) to ```Tutorial.Customer.Model``` 
2. Add a new Folder named **Ops**. This folder will contain all service operations implementations.
3. First, we are going to implement an entity. Create a new ```Code``` component and name it **Customer**. Paste the following code into it:
```csharp
using TomPIT.Annotations.Entities;

namespace Tutorial.Customer;

[Table(Schema = "tutorial")]
internal sealed record Customer : Entity<int>, ICustomer
{
	[Length(128)]
	public string Name { get; init; } = default!;
}
```
This is an implementation of the ```ICustomer``` entity. By putting the ```Table``` attribute we are telling the *Connected* to automatically create a database table for us. There is no need to take care of the database schemas even if we later change the entity structure.
4. Inside the **Ops** folder add a new ```Code``` component named **Insert** and paste the following code into it:
```csharp
using TomPIT.Entities.Storage;

namespace Tutorial.Customer;

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
			throw new NullReferenceException(TomPIT.Strings.ErrEntityExpected);

		return entity.Id;
	}
}
```
This is the implementation if the insert operation. As you can see it's very simple and intuitive. We simply request a storage and convert a ```Dto``` to ```Customer``` entity and by calling the ```Update``` the *Connected* performs a database execute. By setting the ```State``` to ```New``` we are telling the *Connected* it a new record which in turn means it will perform an insert operation.
> *Connected* automatically returns a newly inserted identity value and attaches it to the entity's ```Id``` property.
5. Inside the **Ops** folder create a new ```Code``` component named **Update** and paste the following code into it:
```csharp
using TomPIT.Entities.Storage;

namespace Tutorial.Customer;

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
This operation performs an update on a ```Customer``` entity. It is very similar to the ```Insert``` operation with the exception we first perform a ```Select``` to retrieve an existing ```Customer``` and then we merge a ```DTO``` object with entity.
6. Inside the **Ops** folder create a new ```Code``` component named ***Delete** and paste the following code into it:
```csharp
using TomPIT.Entities.Storage;

namespace Tutorial.Customer;

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
This implementation is even simplier. We just take a ```Dto``` and perform a delete operation by telling the *Connected* the entity's ```State``` is a ```Deleted```.
7. Inside the **Ops** folder create a new ```Code``` component named ***Select*** and paste the folloging code into it:
```csharp
using TomPIT.Entities.Storage;

namespace Tutorial.Customer;

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
This operation reads a single customer from the database based on the supplied ```Id```. As you can see there is not database scripts included, no need to deal with database specifics and no mappings. We simply use LINQ to perform all query operations.
8. Inside the **Ops** folder create a new ```Code``` component named **Query** and paste the following code into it:
```csharp
using TomPIT.Entities.Storage;

namespace Tutorial.Customer;

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
9. Add a new ```Code``` Component  on the root named **CustomerService** and paste the following code into it:
```csharp
namespace Tutorial.Customer;

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

At this point, we have all components needed for the [Service Layer](https://github.com/Tom-PIT/Docs/blob/main/DevelopersGuide/ServiceLayer). This service is fully REST supported.
> For simplicity reasons this tutorial ommits all security aspects of the *Connected*.
## Presentation
Server side is done, let's play with the client part. [Create](https://github.com/Tom-PIT/Docs/blob/main/DevelopersGuide/IDE/CreateMicroservice.md) another microservice named **Turotial.Customer.JS**.
### Adding references
We need to [add](https://github.com/Tom-PIT/Docs/blob/main/DevelopersGuide/IDE/AddReference.md) two additional references to the microservice:
- ```TomPIT.Core.Web.Lib```
- ```TomPIT.Core.Web.Components```
### Proxy
The first component is the proxy which acts and a bridge between [Service Layer](https://github.com/Tom-PIT/Docs/blob/main/DevelopersGuide/ServiceLayer) and a [Presentation Layer](https://github.com/Tom-PIT/Docs/blob/main/DevelopersGuide/PresentationLayer).
Create a new folder named **Proxies** in the root.
Create a new ```File``` component in the **Proxies** folder and name it **CustomerProxy.mjs**. Paste the following code into it:
```javascript
import { ServiceClient } from '@lib';

export class CustomerProxy extends ServiceClient {
   constructor() {
      super('services/customers');
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
As you can see there is not much difference between server and client, operations simply delegate calls to the servee. There is one exception though, the ```bind``` which serves as an [automatic binder](https://github.com/Tom-PIT/Docs/blob/main/DevelopersGuide/PresentationLayer/Data/DtoBinding.md) of the ```Dto``` object into the model.

We must also enable this service to the clients by setting it's ```Url``` property in the [Property Grid](https://github.com/Tom-PIT/Docs/blob/main/DevelopersGuide/IDE/PropertyGrid.md). Enter the value ```services/tutorials/customers```.
### Components
It's time to create UI components. The entire *Connected* UI is componentized which means it's organized into a set of reusable components that can be used independently in other user interfaces as well.
We'll place all components inside the **Customers** folder so you need to create this folder first.
### A Form
This first UI component is the edit form which will serve as the editor for either a new customer or an existing one. We need two files for this, a template and a javascript file. Create a new ```File``` component named **Form.html** and paste the following code into it:
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
This is a simple html markup with one input field for the name property and three buttons. You have probably noticed how clean the design is, with no validation or other unnecessary markup. The *Conencted* will put all pieces together automatically for you.
Now create the ```javascript``` file named **Form.mjs** and paste the following code into it:
```javascript
import { DataBoundComponent } from '@lib/components';

class Form extends DataBoundComponent {
   #form;
   #saveButton;
   #cancelButton;
   #deleteButton;

   async _onConnected() {
      this.#form = await this._renderTemplate(this, null, 'templates/tutorials/customers', 'form');
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

   _onDisconnected() {
      this.#saveButton.removeEventListener('click', this.#saveClick);
      this.#cancelButton.removeEventListener('click', this.#cancelClick);
      this.#deleteButton.removeEventListener('click', this.#deleteClick);

      this.model.removeEventListener('valueChanged', this.#modelValueChanged);
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
Again, it's very simple. We load the template and this component is dealing with is to respond to button clicks and triggers events to which component's clients are hooked.

Enable this component to the clients by setting it's ```Url``` property to the ```components/tutorials/customers/form``` in the [Property Grid](https://github.com/Tom-PIT/Docs/blob/main/DevelopersGuide/IDE/PropertyGrid.md).

## A List
List component will serve as a display for existing customers. Create a new ```File``` component named **List.html** and paste the following code into it:
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
The list component basically wraps the *Connected* table web component and display one column which is bound to the ```name``` property. Let's create it's implementation by adding a new ```File``` component named **List.mjs**. Paste the following code into it:
```javascript
import { DataBoundComponent } from '@lib/components';

class List extends DataBoundComponent {

   constructor() {
      this.model = new Model();
   }

   async _onConnected() {
      await super._renderTemplate(this, null, 'templates/tutorials/customers', 'list');

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
      const link = e.detail.element.selectComponent('a[kind="measureUnit"]');

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
This component simply awaits the datasource to be attached and than displays the existing customers.

Enable this component to the clients by setting it's ```Url``` property to the ```components/tutorials/customers/list``` in the [Property Grid](https://github.com/Tom-PIT/Docs/blob/main/DevelopersGuide/IDE/PropertyGrid.md).

### A container
The last component we are going to create is a container. It a composite component which contains both, a form and a list and enables communication between them.
Create a new ```File``` component named **Container.html** and paste the following code into it:
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
Container contains two sections, one for the list and the other for edit form. It will switch between them accordingly.
Now create another ```File``` component called **Container.mjs** and paste the following code into it:
```javascript
import { DataBoundComponent } from '@lib/components';
import { CustomersProxy } from '@services/tutorials/customers';
import '@components/tutorials/customers/form';
import '@components/tutorials/customers/list';

class Container extends DataBoundComponent {
   #container;
   #list;
   #form;
   #customers = new CustomersProxy();
   #buttonAdd;

   async _onConnected() {
      this.#container = await super._renderTemplate(this, undefined, 'templates/tutorials/customers', 'container');

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

      await this.#service.bind(this.model, 'update', id);

      this.#container.showSection('form');
   }

   #edit = async (e) => {
      await this.#service.bind(this.model, 'update', e.detail.id);

      this.#container.showSection('form');

      this.#buttonAdd.classList.add('d-none');
   }

   #save = async () => {
      if (!this.model.validate())
         return;

      const record = this.model.data;

      if (record.id)
         await this.#service.update(record.id, record.name, record.code, record.precision, record.status);
      else
         await this.#service.insert(record.name, record.code, record.precision, record.status);

      await this.#container.showSection('list');

      this.#buttonAdd.classList.remove('d-none');
   }

   #cancel = async () => {
      await this.#container.showSection('list');

      this.#buttonAdd.classList.remove('d-none');
   }

   #delete = async () => {
      await this.#service.delete(this.model.data.id);
      await this.#container.showSection('list');

      this.#buttonAdd.classList.remove('d-none');
   }

   #add = async () => {
      await this.#service.bind(this.model, 'insert');

      this.#container.showSection('form');

      this.#buttonAdd.classList.add('d-none');
   }
}

customElements.define('customer-container', Container);
```
Set its ```Url``` property to ```components/tutorials/customers/container```.

At this point, we have all components implemented and ready to use.
## Bundling
We are going to perform another task just for the sake of following the *Connected* guidelines. One of the optimization routines is called bundling where we join together similar template files and serve the as a single unit. The easiest way to to is to put all templates in the same folder and the create a new json ```File``` component. Let's add a new component and name it **Customers*.json*. Paste the following code into it:
```json
{
   "files": [
      "/*"
   ]
}
```
Set its ```Url``` property to ```templates/tutorials/customers```.
## The view microservice
by following the *Connected* guidelines we must put views in the separate microservice because their use is optional since components can be hosted in a different context. Let's create a new microservice named **Tutorial.Customer.Views**.
Add the [same references](##adding-references) as for the ``JS`` microservice.
