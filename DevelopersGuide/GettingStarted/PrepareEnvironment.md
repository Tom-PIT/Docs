# Prepare Environment

*Connected* is a development platform that runs on .NET. There are a few prerequisites needed in order to start developing [Microservices](../Microservices/README.md).

## .NET
.NET Framework is the first prerequisite which typically comes with the *Development Environment*, often called **IDE**, so you probably won't need to install it separately. Current version of .NET on which *Connected* runs is **9**.

## Database
*Connected* is typically used for implementing business applications which manipulate with different data structures. Data structures are called [Entities](../ServiceLayer/Entities/README.md) and are commonly stored in a database.

You must provide a database. We'll use a *Microsoft SQL Server Express* throughout the documentation, which can be [downloaded](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) from the official website, so we recommend you to use this version of database for the development purposes.

## IDE
Next, you are going to need an IDE. It can be any IDE that supports .NET development since *Connected* is written in ```C#``` and it's very likely you'll want to develop your server code in ```C#``` as well. Some of the most popular IDE's are:

- [Visual Studio Code ](https://code.visualstudio.com/), supported on *Windows*, *Linux* and *Mac*
- [Visual Studio Community](https://visualstudio.microsoft.com/vs/community), supported only on windows
- [Visual Studio Professional or Enterprise](https://visualstudio.microsoft.com/), supported only on windows
- [JetBrains](https://www.jetbrains.com/rider/)

We recommend you to use *Visual Studio Community* if you're on *Windows* and *Visual Studio Code* if you use either *Linux* or *Mac* operating system.

If you use *Visual Studio Code* you'll need to install **.NET SDK** in order to compile and run server side code.

## Next Steps

- [Create Microservice](Tutorials/CreateMicroservice.md)
