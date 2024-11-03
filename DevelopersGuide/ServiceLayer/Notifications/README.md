# Notifications

*Connected* is an *Event Driven* platform. This means the platform has a strong support for *Event Orchestration* because [Microservice](../../Microservices/README.md) architecture in the combination with [Dependency Injections](../DependencyInjection/README.md) introduces a whole new layer of complexity that needs to be solved in order for [Digital Content](../../Environment/DigitalContent.md) to have all the tools and services at its disposal to achieve demanding goals of digital transformation.

A Typical .NET application a component would subscribe to the event of some service and it would wait for the dispatcher to perform a call. It's not that trivial in platforms such as *Connected* because services provide different scopes, can run in different processes, including clients that want to be up to date with what is happening in the [Service Layer](../../ServiceLayer/README.md) as well.

Luckily, *Connected* provides a complete support for the mentioned challenges. In fact, the complexity of the *Event Orchestration* is completely hidden from the developer and responding to *Events* is really a trivial task.

## Service Layer


## User Layer