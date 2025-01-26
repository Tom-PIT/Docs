# Tutorial: Hello World

As always, the *Hello World* example is one of the first things developers tend to do when they learn about new technology.

This tutorial is exactly that: a *Hello World*.

In this tutorial you'll learn how to create a [Service](../../ServiceLayer/Services/README.md) which is exposed as a REST service over ```HTTP```/```HTTPS``` protocols.

> [!NOTE]
> You will typically create a *Class Library* for each Microservice and then an *Executable* which would reference a set of implemented Microservices but for the sake of simplicity we'll create only an *Executable* in this tutorial.

First, [Create](CreateMicroservice.md) a new Microservice named **HelloWorld** as an *Console Application*.

> [!NOTE]
> Before moving to next steps make sure you've completed all the steps on how to [Create and prepare](CreateMicroservice.md) a Microservice.

Once the project is correctly configured and prepared, open the *Program.cs* file and replace the content with the following code:

```csharp
using Connected;

await Application.StartDefaultApplication(args);
```

The core above simply starts the *Connected* server application with the default implementation which is sufficient in most cases. If you run the program the *Connected* server application starts and waits for the requests. 

## Create a HelloService

At this point we have a perfectly valid *Connected* application up and running so it's time to add a *HelloService*. Create a new file named **HelloService.cs** and paste the following code into it:

``` csharp
using Connected.Annotations;

namespace HelloWorld;

[Service]
internal class HelloService
{

    [ServiceOperation(ServiceOperationVerbs.Get)]
    public string SayHello() => "Hello World!";
}
```

Save the file and run the application. Open the browser and enter the following address into the address bar:
```
http://localhost:5000/helloworld/helloservice/sayhello
```

The browser should display

```
"Hello World!"
```
Congratulations! You've just implemented a first Microservice.

## Next Steps

- [Customers Example](CustomersExample.md)