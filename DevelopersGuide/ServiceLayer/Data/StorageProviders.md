# Storage Providers

In *Connected*, storage is provided by *Storage Providers*. Those providers ensure I/O operations which follow the same guidelines and offer the same experience regardless of the provider.

*Storage Providers* are hidden and you will probably never have a need to deal with them directly. The most common *Storage Provider* is a database provider. *Connected* offer two database *Storage Providers* out of the box:

- Microsoft SQL Server
- PostgreSQL

You will probably want to have only one installed in particular [Instance](../../Environment/Instance.md) because you will likely want to store data only in a single database type.

## Schema

A storage provider usually provides the infrastructure for synchronizing [Entity](../Entities/README.md) schemas. Namely, *Connected* does not require you keep the records of changes to the [Entity](../Entities/README.md) model and then perform synchronization manually but it is completely managed by the infrastructure. Built in *Connected* *Storage Providers* are smart enough to perform all the necessary synchronization on [Start](../../Microservices/Startup.md).

## Query

*Storage Providers* fully supports LINQ operations. This means that they have an integrated *Expression Translators* which translates LINQ expressions into database specific procedural text which is then performed on ```IStorageOperations```. This way the need for writing a database specific code is completely eliminated.

For example, instead of write a stored procedure:

```sql
CREATE PROCEDURE [academy].[project_sel]
    @id int
AS
    SELECT TOP 1 *
    FROM academy.project
    WHERE id = @id;
```
and then a ```C#``` code:

```csharp
using Microsoft.Data.SqlClient;
using System.Data;

using var connection = new SqlConnection("CONNECTION_STRING");

try
{
	var command = connection.CreateCommand();

	command.CommandText = "[academy].[project_sel]";
	command.CommandType = CommandType.StoredProcedure;

	await connection.OpenAsync();

	var reader = await command.ExecuteReaderAsync();

	if(await reader.ReadAsync())
	{
		var result = new Project
		{
			Name = reader.GetString(reader.GetOrdinal("name"))
		};
	}

	reader.Close();

	return result;
}
finally
{
	if(connection.State == System.Data.ConnectionState.Open)
		connection.Close();

	connection.Dispose();
}
```
in *Connected* you simply end up with:
```csharp
return await Storage.Open<Project>().Where(f => f.Id == Dto.Id).AsEntity();
```

The difference is obvious. In *Connected* access to the [Entity](../Entities/README.md) is *one liner* and its schema is fully managed by the *Storage Provider* which means it will create a table and upgrade it according to the changes.

## Transactions

*Storage Providers* also provide complete infrastructure for `creating`, `updating` and `deleting` entities. Again, there is no need to have any knowledge about database languages since it is completely handled by the *Storage Providers*. Inserting a new project would look similar to:

```csharp
await Storage.Open<Project>().Update(Dto.AsEntity<Project>(State.New));
```
It really is that simple. As you can see, the *Storage Providers* play an important role in the *Connected* as you code will be reduced by as much as 90% and no database specific languages are needed. Additionally,  schema synchronization is fully managed by providers which eliminates the risk of errors when upgrading and improves efficiency because the synchronization is part of the [Startup](../../Environment/Startup.md) process.