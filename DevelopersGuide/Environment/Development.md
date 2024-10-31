# Development Instance

*Development Instance* is primarily used by **Developers** and is installed locally. Logically it's part of the [Environment](README.md) but is not technically managed centrally.

You must install your Development Instance by yourself. To install it please follow the [Installation Guide](../../../Docs/GettingStarted/README.md).

The heart of the Development Instance is [Integrated Development Environment](../IDE/README.md), sometimes called **IDE**. You perform all development activities in this environment, from [Modeling](../Microservices/Model.md), Implementing, Testing, and [Versioning](../Deployment/Repositories.md) [Microservices](../Microservices/README.md).

*Development Instance* consists of two [Instances](Instance.md):

- *Development*
- [Quality](Quality.md)

This means that the *Development* and *Quality Instances* share the same configuration but are used by different roles. In fact, **Developers** use the *Quality* Instance for checking the results of the development.

*Connected* is all inclusive platform, which means virtually all source code apart from [Shell](Shell.md) is available in the same environment. This means that [IDE](../IDE/README.md) was also developed by the very same [IDE](../README.md) that is being used for developing either [Core](Core.md) or custom [Digital Content](DigitalContent.md).

This concept has many advantages, the most notable is having all source code in one place, accessible from a single [IDE](../IDE/README.md) and ready for change. This way you can quickly take a look in the implementation of the [Core](Core.md) [Microservices](../Microservices/README.md), debug them or change its features as needed. You don't depend on other development teams to fix bugs and provide hot fixes, you can simply do it by yourself.

The concept comes with a challenges too. Developing [Microservices](../Microservices/README.md) in the [IDE](../IDE/README.md) which runs in the same environment where [Microservices](../Microservices/README.md) run as well requires additional [Instance](Instance.md) to be run in parallel to be able to see compiled changes without restarting the [Instance](Instance.md).

[Microservices](../Microservices/README.md) are [Compiled](Compilation.md) on [Startup](Startup.md) and once compiled they cannot change. This means you must restart the [Instance](Instance.md) to see the changes. *Connected* has a highly optimized [Startup](Startup.md) and it only takes a few seconds to restart the [Quality](Quality.md) [Instance](Instance.md). You don't need to restart *Development Instance*, you always restart the [Quality](Quality.md) [Instance](Instance.md). You can do so by click on the **Restart Quality Instance** button in the [IDE](../IDE/README.md).

You don't have to restart [Quality](Quality.md) [Instance](Instance.md) for every change. Changes to the client code, for example ```javascript```, ```templates``` or ```styles``` are immediately available on the [Quality](Quality.md) [Instance](Instance.md) without restarting.