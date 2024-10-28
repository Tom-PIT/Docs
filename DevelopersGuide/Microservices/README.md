# Microservices

*Connected* offers a Microservice architecture. Microservices enable implementation of the loosely coupled systems which can be dynamically plugged into a complex environment without knowing in advance what set of components will be present.

Microservices can be hosted in-process or out-of-process. In *Connected*, both techniques are used and it's important to know that no changes are needed for either scenario. If the Microservice runs in-process their [Model](Model.md) and implementation is the same as out-of-process. In fact, it's the very same Microservice used on both environments.

## In-process

This is the default behavior where we create a [Deployment Image](../Deployment/Images.md) and then all Microservices run in the same process acting as a big whole. The advantage of this approach is performance and cost optimization, because the communication between microservices takes place in the same process sharing the same resources and there is no need for inter-process communication, serialization and deserialization of requests. Also, there is less computing instances required to run the [Environment](../Environment/README.md).

## Out-of-process

Most resources in the internet will teach you that a microservice is an isolated, self sufficient unit which offers a feature completely independent of other microservices. This is true in some cases but for large scale systems it turns out it's impracticable. However, there are many cases where out-of-process [Environments](../Environment/README.md) are a perfect choice.

Most *Connected* *SaaS* services are standalone [Environments](../Environment/README.md) wether run in your *Subscription* asn single tenant or as a multi tenant in *Connected* Cloud network.

## Concept

Microservice is the root object of all implemented components. All source code and assets reside in the Microservice. There is no other way to add components in *Connected* other than Microservices.

Microservice eventually compiles into *Assembly* as a dynamic link library. Microservice can reference other Microservices and use the components from the referenced Microservices. *Connected* introduces the following types of Microservices:

- [Model](Model.md)
- [Implementation](../ServiceLayer/Services/README.md)
- [Process](../ServiceLayer/Artifacts/Processes.md)
- [JS](../UserLayer/UI/JSMicroservice.md)
- [Views](../UserLayer/UI/ViewMicroservice.md)

The Microservice set above is just a guideline, technically all Microservices are the same and there is no limitation by mixing the components from different Microservice types.

[Model](Model.md), [Implementation](../ServiceLayer/Services/README.md) and [Process](../ServiceLayer/Artifacts/Processes.md) Microservices are [Service Layer](../ServiceLayer/README.md) Microservices whereas [JS](../UserLayer/UI/JSMicroservice.md) and [Views](../UserLayer/UI/ViewMicroservice.md) are [User Layer](../UserLayer/README.md) Microservices.

They differ in programming language and are run in a complete different environments. [Service Layer](../ServiceLayer/README.md) Microservices uses ```C#``` programming language and are run in Cloud, sometimes called Back-end whereas [User Layer](../UserLayer/README.md) Microservices uses ```javascript``` scripting language and are run in *Web Browser*.

## References

Microservices can reference other Microservices but there are several rules that should be followed in order to keep the system manageable over time. For [Service Layer](../ServiceLayer/README.md) Microservices the following rule apply:

- Any references should be made only to [Model](Model.md) Microservices to keep [Environment](../Environment/README.md) loosely coupled yet fully functional

For [User Layer](../UserLayer/README.md) the following rules apply:

- All Microservices should have a reference to **TomPIT.Core.Web.Lib** instead of **TomPIT.Core.Model**
- If the [Resource Strings](../Globalization/ResourceStrings.md) strings are used, the reference should be made to **TomPIT.Core.Model** as well
- The reference should be made for every [JS](../UserLayer/UI/JSMicroservice.md) [Service](../UserLayer/Services/Proxies.md) or [Web Component](../UserLayer/UI/WebComponents.md) used in Microservice
- if [UI Framework](../UserLayer/UIFramework.md) is used, a reference to **TomPIT.Core.Web.Components** is needed
- a [Model](Model.md) [Service Layer](../ServiceLayer/README.md) reference should be made for every [Proxy](../UserLayer/Services/Proxies.md) service

[User Layer](../UserLayer/README.md) is implemented with a ```javascript``` language which is not compiled in advance hence no strongly typed references could be enforced. Technically, a [JS](../UserLayer/UI/JSMicroservice.md) and [View](../UserLayer/UI/ViewMicroservice.md) Microservices can run perfectly fine without any references since there are no compilation units in it.

### Assemblies

You can also reference an *Assembly* directly if you have some source code precompiled and you would like to reuse it in a Microservice. *Connected* expects that an *Assembly* is present somewhere in the file system in the .NET search paths. 

You add a reference to the *Assembly* the same way as by [Add Reference](../IDE/AddReference.md) to the Microservice except that you select **Assemblies** instead of **Microservices**.

### Packages

*Packages* are a more elegant and powerful way to adding non Microservice references instead of *Assemblies*. Namely, references libraries can have dependencies and those dependencies must be provided as well. *Connected* automatically connects to the [Nuget](https://www.nuget.org/) portal and downloads packages when needed. It resolves all references and loads them into memory.

### What Makes a Microservice Microservice?

In fact, there is only one requirement for a Microservice that *Connected* treats Microservice as a Microservice. The following code explains the Microservice identity:

```csharp
using TomPIT.Annotations;

[assembly: MicroService]
```

Each Microservice typically contains **Properties** folder with the **AssemblyInfo.cs** source file in it. The content of the source file shows the preceding code.

The only thing that must be done in order for a Microservice to be treated as a valid *Connected* Microservice is an *Assembly* level *Microservice* attribute.

If this attribute is not present the Microservice is technically still a Microservice, *Connected* will still [Compile](../Environment/Compilation.md) it but it won't perform any [Startup](Startup.md) actions which includes registering services and synchronizing storage schemas. 

- Learn more how to [Create a new Microservice](../GettingStarted/Tutorials/CreateMicroservice.md)