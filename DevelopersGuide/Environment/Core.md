# Core

Core consists of a set of [Microservices](../Microservices/README.md) built on top of the [Shell](Shell.md). It represents the framework with which other [Microservices](../Microservices/README.md) are built.

Core deals with a technology challenges, it offers tools and services with which you solve business problems. For example, the entire [Service Layer](../ServiceLayer/README.md) is part of the Core [Microservices](../Microservices/README.md).

This approach has many advantages. 

## Unified Code Base

First advantage is the same source code base is available to the entire ecosystem. All [Microservices](../Microservices/README.md) follow the same [Guidelines](../Guidelines/README.md) and use the same architecture, patterns, services and base components.

## IDE Accessible
The source code of the Core is available directly from the [Ide](../IDE/README.md) which developers can use for browsing and debugging since the Core is basically a large group of [Microservices](../Microservices/README.md) which handle technology challenges instead of [Digital Content](DigitalContent.md).

## Fixes

Sometimes bugs occur even in the Core [Microservices](../Microservices/README.md), wether we like it or not. But having all code available in the same [IDE](../IDE/README.md) it means we can fix them and continue to work. Once the bug is fixed we can commit changes to the [Repository](../Deployment/Repositories.md) and have a very own contribution to the community. This shortens the development cycles and eliminates often occurred frustrations of the developers who have to wait for external vendor to provide buf fixes. Instead of waiting weeks, often several months, we can continue with work immediately. 

## Improvements

Also, Core is not a feature complete. There will always be a room for improvement. By having the entire source code at your disposal, you can improve the Core as you need. If you are kind enough, you will probably want to share your contribution to the community, just like with bug fixes and this is how the *Connected* ecosystem works, by improving the product by helping to each other. 

## Debugging

*Connected* offers two types of debugging, Server and Client. Client debugging is done directly from the browser, by activating developer console, since the client code is written in ```javascript```. The server side debugging is done with the help of *Visual Studio Code*. *Connected* has their own [Ide](../IDE/README.md) but do not provide debugging experience since it's a world class feature provided by *Visual Studio Code*. *Connected* offers an excellent experience by integrating *Docker Container*, *Visual Studio Code* and an [IDE](../IDE/README.md) with a one click debugging experience.

The more important fact is that you are able to debug the entire Core without any additional configuration and this way you can achieve a really optimal debugging experience.