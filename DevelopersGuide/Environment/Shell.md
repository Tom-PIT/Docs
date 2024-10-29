# Shell

*Connected* consists of a several technology layers, where the innermost layer represents a **Shell**. It's an infrastructure on which all [Microservices](../Microservices/README.md) run. Shell offer only a few features but they are essential for the system to run properly.

The source code for the Shell is available on [Git](https://github.com/Tom-PIT/Connected) and is not hosted on *Connected* repositories since it's not [Microservice](../Microservices/README.md) oriented. It represents a layer below [Microservices](../Microservices/README.md) and is basically a provider for [Microservices](../Microservices/README.md) that they are able to be built at all.

## Configuration

The first important feature is the configuration. *Connected* has a specific component model where every source file or a component consists of at least two files, a configuration file in ```json``` format and a source file. Configuration file contains information about component and its properties that are not present in source files, for example the ```Url``` property of the templates. Each component has an id in the ```Guid``` format which uniquely identifies a component in the entire environment.

*Connected* hosts all source files locally in several folders. It provides services for reading and writing those files and this is the lowest positioned service in the *Shell* architecture.

## Bootstrap

Shell is responsible for the system [Startup](Startup.md). It's an executable component which is booted from the [Docker Container](https://www.docker.com/) and from there on it's a fully responsible for the entire process lifetime. There are many tasks that are performed on [Startup](Startup.md) but the ultimate goal is to setup the environment to the point where it becomes available to client to serve their requests. Once the Shell reaches this stage its role becomes secondary, namely all services are implemented in [Core](Core.md) at they take control of all activities inside the process.

## Compilation

One of the main stages of the *Bootstrap* is to [Compile](Compilation.md) the [Microservices](../Microservices/README.md). They are compiled as needed but if they need to, they are always compiled on [Startup](Startup.md).

## Packages

[Microservices](../Microservices/README.md) often need to reference external libraries in order to function properly. The most commonly used references are [NuGet](https://www.nuget.org/) packages, because they are self contained compositions that provide all the necessary information how a library is organized and what *Assemblies* it needs to load.

*Shell* contains all the necessary services to download, extract, load and manage [NuGet](https://www.nuget.org/) packages and include the necessary references to [Microservices](../Microservices/README.md).

## Deployment

*Connected* is dynamically plugged platform where the *Shell* represents a fixed, non changeable infrastructure, but the set of installed [Microservices](../Microservices/README.md) are completely dynamic. Basically, the [Instance](Instance.md) is initially completely empty, without a single [Microservice](../Microservices/README.md). Once created, it expects [Microservices](../Microservices/README.md) to be deployed in it from the external source. For *Connected* Cloud environments, public and private, they are always [Deployed](../Deployment/README.md) from the [Connected Portal](ConnectedPortal.md). For On-Prem environments, they need to be [Deployed](../Deployment/README.md) manually. 

*Shell* takes care of the entire [Deployment](../Deployment/README.md) process by performing all the necessary actions for every [Microservice](../Microservices/README.md) to be deployed consistently.

## Shell Services

As a developer, you'll probably never need any of the services offered by a *Shell* unless you will extend [Ide](../IDE/README.md) features or if you will intend to implement some analysis services. In those scenarios, below are a few services that might come useful:

- ```TomPIT.ComponentModel.IComponentService```
- ```TomPIT.ComponentModel.IMicroServiceService```
- ```TomPIT.Design.IDesignService```
- ```TomPIT.Storage.IStorageService```
- ```TomPIT.Compilation.INuGetService```

The entire [Core](Core.md) was built with the use of the services stated above, including the [IDE](../IDE/README.md).

All services are available from the *Shell* container directly, for example:

```csharp
using TomPIT;

public void Foo()
{
    var design = Shell.GetService<IDesignService>();
    ...
}
```