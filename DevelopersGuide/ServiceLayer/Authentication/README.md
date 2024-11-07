# Authentication

Authentication is the process where the [Identity](../../Security/Identities.md) of the target context is resolving. A Context can be a Http request, a Tcp request, a Web Socket request or just a simple [IContext](../../ServiceLayer/IContext.md) where we want to set an Identity.

If the Authentication process resolves an Identity, the context is **Authenticated**. If not, the context is regarded as **Anonymous**. Authentication is not the same as [Authorization](../../Security/Authorization.md) because the goal of the Authentication is to resolve the Identity whereas the goal of the Authorization is to resolve wether the Authenticated Identity can perform specific action or can access the requested resource.

An Identity can be any Entity which derives from an `TomPIT.Identities.IIdentity` and which is able to provide a property named `Token`. It can be `User`, `Device`, `RemoteService` or any other entity that can play an identity role.

*Connected* has an open Authentication model which means you can implement your own Authentication mechanism to authenticate the specific context.

## IAuthenticationService

`IAuthenticationService` provides Identity for the current scope. `IAuthenticationService` is available from the [Dependency Injection](../DependencyInjection/README.md) container as a `Scoped` service.

To perform a impersonation you can always set the `Identity` property of this service to continue scope with a different Identity.

The following code shows how can you retrieve a current Identity:

```csharp
using TomPIT.Authentication;

namespace Connected.Academy;

internal sealed class Delete : ServiceAction<PrimaryKeyDto<int>>
{
	public Delete(IAuthenticationService authentication)
	{
		Authentication = authentication;
	}

	private IAuthenticationService Authentication { get; }

	protected override async Task OnInvoke()
	{
		var token = Authentication.Identity?.Token;

        ...

        await Task.CompletedTask;
	}
}
```

## IAuthenticationProvider

To implement a custom authentication you should implement an `IAuthenticationProvider`. Implementing this provider is straightforward since there is, as is the case with virtually all *Connected* [Middleware](../../ServiceLayer/Middleware.md) components, only one method to implement, `Invoke`. The passed [Dto](../Services/Dto.md) contains information about `Schema` and `Token` that has been passed to the scope.

There are some basic implementations already available:

- BasicAuthentication
- BearerAuthentication

The mentioned implementations are `abstract` and they provide the necessary values, but the actual authentication is left to implementors. For example, the default `BasicAuthentication` looks like:

```csharp
using Microsoft.AspNetCore.Http;
using TomPIT.Authentication;
using Microsoft.Extensions.DependencyInjection;
using TomPIT.Identities;

namespace TomPIT.Authentication;

internal sealed class Authentication : BasicAuthentication
{
	protected override async Task OnInvoke()
	{
		if (UserName is null || Password is null)
			return;

		using var ctx = Bootstrapper.ServiceProvider.CreateContext();

		if (ctx is null)
			return;

		var authentication = ctx.GetService<IAuthenticationService>();

		if (authentication is null)
			return;

		var users = ctx.GetService<IUserService>();

		if (users is null)
			return;

		var user = await users.Select(new SelectUserDto
		{
			User = UserName,
			Password = Password
		});

		if (user is null)
			return;

		authentication.Identity = user;
	}
}
```
If you are not happy with the default implementation you exclude `TomPIT.Core.Authentication.Basic` from the [Deployment Image](../../Deployment/Images.md) and implement your own.

---

**Next Steps**

- [Authentication Providers](Providers.md)