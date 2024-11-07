# Authentication Providers

*Connected* does not have a strict user based authentication system but rather keeps the infrastructure open with the goal to offer a maximum flexibility.

The main goal of the Authentication process is to find out if the current scope has a valid [Identity](../../Security/Identities.md). It's not necessary the Identity represents an `IUser`. The Identity can be anything from Users, Devices, Equipment or simply a REST Service. This way, we can implement any authentication mechanism we want. We can provide many different Authentication providers and all of them will execute one after another and they will try the same thing, to find an Identity for the passed `AuthenticateDto` which contains `Schema` and `Token`.

An `IAuthenticationProvider`, should it finds an Identity for the Dto, should set a valid Identity in the `IAuthenticationService`. The Identity requires only one property, the `Token`. `Token` should be unique across the entire system and across all providers so the clients of the `IAuthenticationService` will be able to retrieve additional information about the Identity if needed.

`IAuthenticationProvider` is [Middleware](../../ServiceLayer/Middleware.md) which means it gets automatically registered in the [Dependency Injection](../DependencyInjection/README.md) container.

For implementing the custom provider you have two options:

- inherit provider from one of the default implementations
- implement a provider from scratch

## Default Implementations

*Connected* ships with two abstract providers:

- BasicAuthentication
- BearerAuthentication

Those are abstract implementations so in order to make them work, you must implement your own provider and inherit from one of the mentioned.

Basic provider will provide `UserName` and `Password` if they are available where Bearer provider will provide a bearer `Token`.

## Implement From Scratch

If none of the above schemas work for you, you can implement a custom provider. Even for a completely custom provider there is an abstract implementation. For example, a custom implementation will looks something like:

```csharp
using TomPIT.Authentication;

namespace Connected.Academy;

internal sealed class FileStorageAuthentication : AuthenticationProvider
{
	protected override async Task OnInvoke()
	{
      if(!string.Equals(Dto.Schema, "SSO", StringComparison.OrdinalIgnoreCase))
      return;

      //TODO: perform a lookup in the shared authentication repository for the specified token.

      await Task.CompletedTask;
	}
}
```